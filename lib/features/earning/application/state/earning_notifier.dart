import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_dependency.dart';
import 'package:driver_analytics_app/features/earning/application/state/earning_state.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_adjustment_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_promotion_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_ride_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/delete_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/get_earnings_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/update_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarningNotifier extends Notifier<EarningState> {
  late final GetEarningsUseCase _getEarningsUseCase;
  late final CreateRideEarningUseCase _createRideEarningUseCase;
  late final CreatePromotionEarningUseCase _createPromotionEarningUseCase;
  late final CreateAdjustmentEarningUseCase _createAdjustmentEarningUseCase;
  late final UpdateEarningUseCase _updateEarningUseCase;
  late final DeleteEarningUseCase _deleteEarningUseCase;

  @override
  EarningState build() {
    _getEarningsUseCase = ref.read(getEarningsUseCaseProvider);
    _createRideEarningUseCase = ref.read(createRideEarningUseCaseProvider);
    _createPromotionEarningUseCase = ref.read(createPromotionEarningUseCaseProvider);
    _createAdjustmentEarningUseCase = ref.read(createAdjustmentEarningUseCaseProvider);
    _updateEarningUseCase = ref.read(updateEarningUseCaseProvider);
    _deleteEarningUseCase = ref.read(deleteEarningUseCaseProvider);
    return const EarningState();
  }

  Future<void> loadEarnings() async {
    _startLoading();
    try {
      final earnings = await _getEarningsUseCase.execute();
      state = state.copyWith(
        status: LoadStatus.loaded,
        earnings: earnings,
        clearError: true,
        clearValidationFailures: true,
      );
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> createRideEarning({
    String? shiftId,
    required DateTime occurredAt,
    String? description,
    required RideApp app,
    required RideServiceType serviceType,
    required double fare,
    double surge = 0,
    double tip = 0,
    required int durationSeconds,
    required double distanceKm,
    required RideStatus status,
    String? pickupCep,
    String? destinationCep,
    String? pickupDistrictId,
    String? destinationDistrictId,
  }) async {
    _clearErrors();
    final result = await _createRideEarningUseCase.execute(
      shiftId: shiftId,
      occurredAt: occurredAt,
      description: description,
      app: app,
      serviceType: serviceType,
      fare: fare,
      surge: surge,
      tip: tip,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      status: status,
      pickupCep: pickupCep,
      destinationCep: destinationCep,
      pickupDistrictId: pickupDistrictId,
      destinationDistrictId: destinationDistrictId,
    );
    switch (result) {
      case Success():
        await loadEarnings();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> createPromotionEarning({
    String? shiftId,
    required DateTime occurredAt,
    required double amount,
    String? description,
  }) async {
    _clearErrors();
    final result = await _createPromotionEarningUseCase.execute(
      shiftId: shiftId,
      occurredAt: occurredAt,
      amount: amount,
      description: description,
    );
    switch (result) {
      case Success():
        await loadEarnings();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> createAdjustmentEarning({
    String? shiftId,
    required DateTime occurredAt,
    required double amount,
    String? description,
  }) async {
    _clearErrors();
    final result = await _createAdjustmentEarningUseCase.execute(
      shiftId: shiftId,
      occurredAt: occurredAt,
      amount: amount,
      description: description,
    );
    switch (result) {
      case Success():
        await loadEarnings();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> updateEarning(EarningEntity earning) async {
    _clearErrors();
    final result = await _updateEarningUseCase.execute(earning: earning);
    switch (result) {
      case Success():
        await loadEarnings();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> deleteEarning(String earningId) async {
    _clearErrors();
    final result = await _deleteEarningUseCase.execute(earningId: earningId);
    switch (result) {
      case Success():
        await loadEarnings();
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
    state = state.copyWith(clearError: true, clearValidationFailures: true);
  }

  void _setError(Object error) {
    state = state.copyWith(status: LoadStatus.error, error: error);
  }
}