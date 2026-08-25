import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/inputs/pause_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_dependency.dart';
import 'package:driver_analytics_app/features/shift/application/state/shift_state.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/create_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/delete_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/get_shifts_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/update_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

class ShiftNotifier extends Notifier<ShiftState> {
  late final GetShiftsUseCase _getShiftsUseCase;
  late final CreateShiftUseCase _createShiftUseCase;
  late final UpdateShiftUseCase _updateShiftUseCase;
  late final DeleteShiftUseCase _deleteShiftUseCase;

  @override
  ShiftState build() {
    _getShiftsUseCase = ref.read(getShiftsUseCaseProvider);
    _createShiftUseCase = ref.read(createShiftUseCaseProvider);
    _updateShiftUseCase = ref.read(updateShiftUseCaseProvider);
    _deleteShiftUseCase = ref.read(deleteShiftUseCaseProvider);
    return const ShiftState();
  }

  Future<void> loadShifts() async {
    _startLoading();
    try {
      final shifts = await _getShiftsUseCase.execute();
      state = state.copyWith(
        status: LoadStatus.loaded,
        shifts: shifts,
        clearError: true,
        clearValidationFailures: true,
      );
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> createShift({
    required double initialKm,
    required DateTime startTime,
    required ShiftStatus status,
    double? finalKm,
    double? earnings,
    DateTime? endTime,
    List<PauseInput> pauses = const [],
  }) async {
    _clearErrors();
    final result = await _createShiftUseCase.execute(
      initialKm: initialKm,
      finalKm: finalKm,
      earnings: earnings,
      startTime: startTime,
      endTime: endTime,
      status: status,
      pauses: pauses,
    );
    switch (result) {
      case Success():
        await loadShifts();
      case Failure():
        state = state.copyWith(
          validationFailures: result.error,
        );
    }
  }

  Future<void> updateShift(ShiftEntity shift) async {
    _clearErrors();
    final result = await _updateShiftUseCase.execute(
      shift: shift,
    );
    switch (result) {
      case Success():
        await loadShifts();
      case Failure():
        state = state.copyWith(
          validationFailures: result.error,
        );
    }
  }

  Future<void> deleteShift(String shiftId) async {
    _clearErrors();
    final result = await _deleteShiftUseCase.execute(
      shiftId: shiftId,
    );
    switch (result) {
      case Success():
        await loadShifts();
      case Failure():
        _setError(result.error);
    }
  }

  void _startLoading() {
    state = state.copyWith(
      status: LoadStatus.loading,
      clearError: true,
      clearValidationFailures: true,
    );
  }

  void _clearErrors() {
    state = state.copyWith(
      clearError: true,
      clearValidationFailures: true,
    );
  }

  void _setError(Object error) {
    state = state.copyWith(
      status: LoadStatus.error,
      error: error,
    );
  }
}
