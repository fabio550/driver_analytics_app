import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_dependency.dart';
import 'package:driver_analytics_app/features/shift/application/state/active_shift_state.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_dependency.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/pause_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/confirm_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/delete_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/finish_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/resume_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/start_shift_use_case.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _ShiftResult
    = Result<ShiftEntity, List<ValidationFailure<ShiftField>>>;

class ActiveShiftNotifier extends Notifier<ActiveShiftState> {
  late final StartShiftUseCase _startShiftUseCase;
  late final PauseShiftUseCase _pauseShiftUseCase;
  late final ResumeShiftUseCase _resumeShiftUseCase;
  late final FinishShiftUseCase _finishShiftUseCase;
  late final ConfirmShiftUseCase _confirmShiftUseCase;
  late final DeleteShiftUseCase _deleteShiftUseCase;

  @override
  ActiveShiftState build() {
    _startShiftUseCase = ref.read(startShiftUseCaseProvider);
    _pauseShiftUseCase = ref.read(pauseShiftUseCaseProvider);
    _resumeShiftUseCase = ref.read(resumeShiftUseCaseProvider);
    _finishShiftUseCase = ref.read(finishShiftUseCaseProvider);
    _confirmShiftUseCase = ref.read(confirmShiftUseCaseProvider);
    _deleteShiftUseCase = ref.read(deleteShiftUseCaseProvider);
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

    Future<void> finish({
    required double finalKm,
    double? earnings,
  }) async {
    final shift = state.shift;
    if (shift == null) return;

    _startSubmitting();
    final result = await _finishShiftUseCase.execute(
      shift: shift,
      now: DateTime.now(),
      finalKm: finalKm,
      earnings: earnings,
    );
    _applyResult(result);
  }

  /// Envia a jornada finalizada como definitiva (status `submitted`).
  /// Retorna `true` em caso de sucesso, já limpando o estado local.
  Future<bool> confirm() async {
    final shift = state.shift;
    if (shift == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    final result = await _confirmShiftUseCase.execute(shift: shift);
    switch (result) {
      case Success():
        state = const ActiveShiftState();
        return true;
      case Failure(:final error):
        state = state.copyWith(isSubmitting: false, error: error);
        return false;
    }
  }

  /// Descarta a jornada (finalizada ou não), apagando o rascunho já
  /// persistido. Retorna `true` em caso de sucesso, já limpando o estado.
  Future<bool> discard() async {
    final shift = state.shift;
    if (shift == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    final result = await _deleteShiftUseCase.execute(shiftId: shift.id);
    switch (result) {
      case Success():
        state = const ActiveShiftState();
        return true;
      case Failure(:final error):
        state = state.copyWith(isSubmitting: false, error: error);
        return false;
    }
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
