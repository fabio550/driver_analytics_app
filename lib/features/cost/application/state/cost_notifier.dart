import 'package:driver_analytics_app/core/domain/result/result.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_dependency.dart';
import 'package:driver_analytics_app/features/cost/application/state/cost_load_status.dart';
import 'package:driver_analytics_app/features/cost/application/state/cost_state.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/create_expense_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/create_fuel_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/create_maintenance_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/delete_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/get_costs_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/update_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CostNotifier extends Notifier<CostState> {
  late final GetCostsUseCase _getCostsUseCase;
  late final CreateFuelCostUseCase _createFuelCostUseCase;
  late final CreateMaintenanceCostUseCase _createMaintenanceCostUseCase;
  late final CreateExpenseCostUseCase _createExpenseCostUseCase;
  late final UpdateCostUseCase _updateCostUseCase;
  late final DeleteCostUseCase _deleteCostUseCase;

  @override
  CostState build() {
    _getCostsUseCase = ref.read(getCostsUseCaseProvider);
    _createFuelCostUseCase = ref.read(createFuelCostUseCaseProvider);
    _createMaintenanceCostUseCase =
        ref.read(createMaintenanceCostUseCaseProvider);
    _createExpenseCostUseCase = ref.read(createExpenseCostUseCaseProvider);
    _updateCostUseCase = ref.read(updateCostUseCaseProvider);
    _deleteCostUseCase = ref.read(deleteCostUseCaseProvider);
    return const CostState();
  }

  Future<void> loadCosts() async {
    _startLoading();
    try {
      final costs = await _getCostsUseCase.execute();
      state = state.copyWith(
        status: CostLoadStatus.loaded,
        costs: costs,
        clearError: true,
        clearValidationFailures: true,
      );
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> createFuelCost({
    required FuelSubcategory subcategory,
    required double amount,
    required DateTime date,
    required double odometerKm,
    required double quantity,
    bool isFullTank = false,
    bool previousFillUpMissing = false,
    String? description,
  }) async {
    _clearErrors();
    final result = await _createFuelCostUseCase.execute(
      subcategory: subcategory,
      amount: amount,
      date: date,
      odometerKm: odometerKm,
      quantity: quantity,
      isFullTank: isFullTank,
      previousFillUpMissing: previousFillUpMissing,
      description: description,
    );
    switch (result) {
      case Success():
        await loadCosts();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> createMaintenanceCost({
    required MaintenanceSubcategory subcategory,
    required double amount,
    required DateTime date,
    double? odometerKm,
    String? description,
  }) async {
    _clearErrors();
    final result = await _createMaintenanceCostUseCase.execute(
      subcategory: subcategory,
      amount: amount,
      date: date,
      odometerKm: odometerKm,
      description: description,
    );
    switch (result) {
      case Success():
        await loadCosts();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> createExpenseCost({
    required ExpenseSubcategory subcategory,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    _clearErrors();
    final result = await _createExpenseCostUseCase.execute(
      subcategory: subcategory,
      amount: amount,
      date: date,
      description: description,
    );
    switch (result) {
      case Success():
        await loadCosts();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> updateCost(CostEntity cost) async {
    _clearErrors();
    final result = await _updateCostUseCase.execute(cost: cost);
    switch (result) {
      case Success():
        await loadCosts();
      case Failure():
        state = state.copyWith(validationFailures: result.error);
    }
  }

  Future<void> deleteCost(String costId) async {
    _clearErrors();
    final result = await _deleteCostUseCase.execute(costId: costId);
    switch (result) {
      case Success():
        await loadCosts();
      case Failure():
        _setError(result.error);
    }
  }

  void _startLoading() {
    state = state.copyWith(
      status: CostLoadStatus.loading,
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
      status: CostLoadStatus.error,
      error: error,
    );
  }
}
