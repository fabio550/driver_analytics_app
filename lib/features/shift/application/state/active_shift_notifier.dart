import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_dependency.dart';
import 'package:driver_analytics_app/features/shift/application/state/active_shift_state.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/pause_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/resume_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/start_shift_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveShiftNotifier extends Notifier<ActiveShiftState> {
  late final StartShiftUseCase _startShiftUseCase;
  late final PauseShiftUseCase _pauseShiftUseCase;
  late final ResumeShiftUseCase _resumeShiftUseCase;

  @override
  ActiveShiftState build() {
    _startShiftUseCase = ref.read(startShiftUseCaseProvider);
    _pauseShiftUseCase = ref.read(pauseShiftUseCaseProvider);
    _resumeShiftUseCase = ref.read(resumeShiftUseCaseProvider);
    return const ActiveShiftState();
  }

  Future<void> start(double initialKm) async {
    _startSubmitting();
    final result = await _startShiftUseCase.execute(
      initialKm: initialKm,
      now: DateTime.now(),
    );
    _applyResult(result);
  }

  Future<void> pause() async {
    final shift = state.shift;
    if (shift == null) return;

    _startSubmitting();
    final result = await _pauseShiftUseCase.execute(
      shift: shift,
      now: DateTime.now(),
    );
    _applyResult(result);
  }

  Future<void> resume() async {
    final shift = state.shift;
    if (shift == null) return;

    _startSubmitting();
    final result = await _resumeShiftUseCase.execute(
      shift: shift,
      now: DateTime.now(),
    );
    _applyResult(result);
  }

  void _startSubmitting() {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearValidationFailures: true,
    );
  }

  void _applyResult(_ShiftResult result) {
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          shift: value,
          isSubmitting: false,
        );
      case Failure(:final error):
        state = state.copyWith(
          isSubmitting: false,
          validationFailures: error,
        );
    }
  }
}
