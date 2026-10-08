import 'dart:async';
import 'dart:io';

import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_dependency.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/application/providers/ride_import_dependency.dart';
import 'package:driver_analytics_app/features/earning/application/state/ride_import_state.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_ride_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/preview_ride_import_use_case.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
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
      clearProgress: true,
    );
    await _runPreview(rawText);
  }

  /// Roda OCR on-device sobre o print selecionado e manda o texto
  /// reconhecido pro mesmo pipeline de [preview].
  Future<void> previewFromImagePath(String imagePath) async {
    state = state.copyWith(
      status: LoadStatus.loading,
      clearError: true,
      clearResult: true,
      clearProgress: true,
    );

    try {
      final recognizer = ref.read(textRecognizerServiceProvider);
      final rawText = await recognizer.recognizeText(imagePath);
      await _runPreview(rawText);
    } catch (error) {
      state = state.copyWith(status: LoadStatus.error, error: error);
    }
  }

  /// Extrai frames de um vídeo (gravação de tela rolando a lista de
  /// corridas — alternativa ao print quando a Uber bloqueia screenshot
  /// nessa tela), roda OCR em cada frame e junta todo o texto
  /// reconhecido num só bloco antes de mandar pro mesmo pipeline de
  /// [preview]. Frames sobrepostos geram a mesma corrida mais de uma
  /// vez no texto — o dedup em [PreviewRideImportUseCase] descarta a
  /// repetição antes de virar candidato.
  Future<void> previewFromVideoPath(String videoPath) async {
    state = state.copyWith(
      status: LoadStatus.loading,
      clearError: true,
      clearResult: true,
      clearProgress: true,
    );

    try {
      final extractor = ref.read(videoFrameExtractorServiceProvider);
      final recognizer = ref.read(mlKitTextRecognizerServiceProvider);
      final framePaths = await extractor.extractFrames(videoPath);

      if (framePaths.isEmpty) {
        throw StateError('Não consegui extrair nenhum frame desse vídeo.');
      }

      final texts = <String>[];
      for (var i = 0; i < framePaths.length; i++) {
        final framePath = framePaths[i];
        try {
          texts.add(await recognizer.recognizeText(framePath));
        } finally {
          unawaited(File(framePath).delete().catchError((_) => File(framePath)));
        }

        state = state.copyWith(
          frameProgressCurrent: i + 1,
          frameProgressTotal: framePaths.length,
        );
      }

      await _runPreview(texts.join('\n'));
    } catch (error) {
      state = state.copyWith(status: LoadStatus.error, error: error);
    }
  }

  Future<void> _runPreview(String rawText) async {
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
        rawText: rawText,
      );
    } catch (error) {
      state = state.copyWith(status: LoadStatus.error, error: error, rawText: rawText);
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
  ///
  /// Quando [shiftId] é null (import aberto fora do fluxo de finalizar
  /// jornada), as corridas criadas ficam sem jornada — guardadas em
  /// [RideImportState.unassignedImportedRides] pra a tela oferecer criar
  /// uma jornada em seguida e associar via [assignShiftToPendingRides].
  Future<void> confirmImport({String? shiftId}) async {
    state = state.copyWith(isSaving: true);

    var imported = 0;
    final createdRides = <RideEarningEntity>[];

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
        case Success(value: final earning):
          imported++;
          if (shiftId == null && earning is RideEarningEntity) {
            createdRides.add(earning);
          }
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
      unassignedImportedRides: createdRides.isEmpty ? null : createdRides,
      clearUnassignedImportedRides: createdRides.isEmpty,
    );
  }

  /// Associa [shiftId] a todas as corridas guardadas em
  /// [RideImportState.unassignedImportedRides] (import sem jornada,
  /// seguido da criação de uma) e limpa a lista. Passa por
  /// [EarningNotifier.updateEarning] em vez de ir direto no repositório
  /// pra manter o estado global de ganhos (Ganhos, Home) atualizado.
  Future<void> assignShiftToPendingRides(String shiftId) async {
    final rides = state.unassignedImportedRides;
    if (rides == null || rides.isEmpty) return;

    final earningNotifier = ref.read(earningNotifierProvider.notifier);
    for (final ride in rides) {
      await earningNotifier.updateEarning(ride.copyWith(shiftId: shiftId));
    }

    state = state.copyWith(clearUnassignedImportedRides: true);
  }

  /// Descarta as corridas pendentes de jornada sem associar nenhuma —
  /// usado quando o usuário cancela o formulário de jornada oferecido
  /// após a importação. As corridas continuam salvas, só sem jornada.
  void discardPendingShiftRides() {
    if (state.unassignedImportedRides == null) return;
    state = state.copyWith(clearUnassignedImportedRides: true);
  }

  void reset() {
    state = const RideImportState();
  }
}
