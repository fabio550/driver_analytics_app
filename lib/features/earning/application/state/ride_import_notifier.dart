import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_dependency.dart';
import 'package:driver_analytics_app/features/earning/application/providers/ride_import_dependency.dart';
import 'package:driver_analytics_app/features/earning/application/state/ride_import_state.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_ride_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/preview_ride_import_use_case.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideImportNotifier extends Notifier<RideImportState> {
  late final RideParser _parser;
  late final EarningRepository _repository;
  late final CreateRideEarningUseCase _createRideEarningUseCase;

  @override
  RideImportState build() {
    _parser = ref.read(rideParserProvider);
    _repository = ref.read(earningRepositoryProvider);
    _createRideEarningUseCase = ref.read(createRideEarningUseCaseProvider);
    return const RideImportState();
  }

  /// Faz o parser + geo lookup + checagem de duplicata pro texto colado.
  /// Não salva nada ainda — só monta a prévia pra o usuário confirmar.
  Future<void> preview(String rawText) async {
    state = state.copyWith(
      status: LoadStatus.loading,
      clearError: true,
      clearResult: true,
    );

    try {
      final geoLookupService = await ref.read(geoLookupServiceProvider.future);
      final useCase = PreviewRideImportUseCase(
        parser: _parser,
        geoLookupService: geoLookupService,
        repository: _repository,
      );

      final candidates = await useCase.execute(rawText);
      final selected = {
        for (var i = 0; i < candidates.length; i++)
          if (candidates[i].isImportable) i,
      };

      state = state.copyWith(
        status: LoadStatus.loaded,
        candidates: candidates,
        selectedIndexes: selected,
      );
    } catch (error) {
      state = state.copyWith(status: LoadStatus.error, error: error);
    }
  }

  void toggleSelected(int index) {
    final selected = Set<int>.from(state.selectedIndexes);
    if (!selected.remove(index)) {
      selected.add(index);
    }
    state = state.copyWith(selectedIndexes: selected);
  }

  /// Cria uma ride por candidato selecionado e importável. Candidatos
  /// duplicados ou com tipo de serviço não reconhecido nunca são salvos,
  /// mesmo que de algum jeito acabem marcados como selecionados.
  Future<void> confirmImport({String? shiftId}) async {
    state = state.copyWith(isSaving: true);

    var imported = 0;

    for (final index in state.selectedIndexes) {
      final candidate = state.candidates[index];
      if (!candidate.isImportable) continue;

      final result = await _createRideEarningUseCase.execute(
        shiftId: shiftId,
        occurredAt: candidate.occurredAt,
        app: candidate.app,
        serviceType: candidate.serviceType!,
        fare: candidate.fareBrl,
        surge: candidate.surgeBrl,
        tip: candidate.tipBrl,
        durationSeconds: candidate.durationSeconds,
        distanceKm: candidate.distanceKm,
        status: candidate.status,
        pickupCep: candidate.pickupCep,
        destinationCep: candidate.destinationCep,
        pickupDistrictId: candidate.pickupGeo?.districtId.toString(),
        destinationDistrictId: candidate.destinationGeo?.districtId.toString(),
        dedupHash: candidate.dedupHash,
      );

      switch (result) {
        case Success():
          imported++;
        case Failure():
          break;
      }
    }

    final skipped = state.candidates.length - imported;

    state = state.copyWith(
      status: LoadStatus.initial,
      candidates: const [],
      selectedIndexes: const {},
      isSaving: false,
      lastImportedCount: imported,
      lastSkippedCount: skipped,
    );
  }

  void reset() {
    state = const RideImportState();
  }
}
