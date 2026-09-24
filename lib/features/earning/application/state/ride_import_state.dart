import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/ride_import_candidate.dart';

class RideImportState {
  final LoadStatus status;
  final List<RideImportCandidate> candidates;
  final Set<int> selectedIndexes;
  final Object? error;
  final bool isSaving;
  final int? lastImportedCount;
  final int? lastSkippedCount;

  const RideImportState({
    this.status = LoadStatus.initial,
    this.candidates = const [],
    this.selectedIndexes = const {},
    this.error,
    this.isSaving = false,
    this.lastImportedCount,
    this.lastSkippedCount,
  });

  RideImportState copyWith({
    LoadStatus? status,
    List<RideImportCandidate>? candidates,
    Set<int>? selectedIndexes,
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
      error: clearError ? null : error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
      lastImportedCount:
          clearResult ? null : lastImportedCount ?? this.lastImportedCount,
      lastSkippedCount:
          clearResult ? null : lastSkippedCount ?? this.lastSkippedCount,
    );
  }
}
