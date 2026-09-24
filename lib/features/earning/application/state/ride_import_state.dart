import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/ride_import_candidate.dart';

class RideImportState {
  final LoadStatus status;
  final List<RideImportCandidate> candidates;
  final Set<int> selectedIndexes;

  /// Texto que o OCR (ou o texto colado manualmente) produziu na última
  /// tentativa — guardado mesmo quando zero corridas foram reconhecidas,
  /// pra dar pra conferir o que saiu e ajustar o parser se precisar.
  final String? rawText;

  final Object? error;
  final bool isSaving;
  final int? lastImportedCount;
  final int? lastSkippedCount;

  const RideImportState({
    this.status = LoadStatus.initial,
    this.candidates = const [],
    this.selectedIndexes = const {},
    this.rawText,
    this.error,
    this.isSaving = false,
    this.lastImportedCount,
    this.lastSkippedCount,
  });

  RideImportState copyWith({
    LoadStatus? status,
    List<RideImportCandidate>? candidates,
    Set<int>? selectedIndexes,
    String? rawText,
    Object? error,
    bool? isSaving,
    int? lastImportedCount,
    int? lastSkippedCount,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RideImportState(
      status: status ?? this.status,
      candidates: candidates ?? this.candidates,
      selectedIndexes: selectedIndexes ?? this.selectedIndexes,
      rawText: rawText ?? this.rawText,
      error: clearError ? null : error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
      lastImportedCount:
          clearResult ? null : lastImportedCount ?? this.lastImportedCount,
      lastSkippedCount:
          clearResult ? null : lastSkippedCount ?? this.lastSkippedCount,
    );
  }
}
