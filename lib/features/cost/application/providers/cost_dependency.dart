import 'package:driver_analytics_app/core/infrastructure/database/app_database_provider.dart';
import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_provider.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/create_expense_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/create_fuel_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/create_maintenance_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/delete_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/get_costs_use_case.dart';
import 'package:driver_analytics_app/features/cost/application/use_cases/update_cost_use_case.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/cost/domain/validators/cost_validator.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/cost_repository_impl.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/mappers/cost_mapper.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/mappers/fuel_cost_mapper.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/mappers/maintenance_cost_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final costMapperProvider = Provider<CostMapper>((ref) {
  return const CostMapper();
});

final fuelCostMapperProvider = Provider<FuelCostMapper>((ref) {
  return const FuelCostMapper();
});

final maintenanceCostMapperProvider = Provider<MaintenanceCostMapper>((ref) {
  return const MaintenanceCostMapper();
});

final costRepositoryProvider = Provider<CostRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final mapper = ref.watch(costMapperProvider);
  final fuelMapper = ref.watch(fuelCostMapperProvider);
  final maintenanceMapper = ref.watch(maintenanceCostMapperProvider);
  return CostRepositoryImpl(
    database: database,
    mapper: mapper,
    fuelMapper: fuelMapper,
    maintenanceMapper: maintenanceMapper,
  );
});

final costValidatorProvider = Provider<CostValidator>((ref) {
  return const CostValidator();
});

final createFuelCostUseCaseProvider = Provider<CreateFuelCostUseCase>((ref) {
  final repository = ref.watch(costRepositoryProvider);
  final validator = ref.watch(costValidatorProvider);
  final idGenerator = ref.watch(uuidGeneratorProvider);
  return CreateFuelCostUseCase(
    repository: repository,
    validator: validator,
    idGenerator: idGenerator,
  );
});

final createMaintenanceCostUseCaseProvider =
    Provider<CreateMaintenanceCostUseCase>((ref) {
  final repository = ref.watch(costRepositoryProvider);
  final validator = ref.watch(costValidatorProvider);
  final idGenerator = ref.watch(uuidGeneratorProvider);
  return CreateMaintenanceCostUseCase(
    repository: repository,
    validator: validator,
    idGenerator: idGenerator,
  );
});

final createExpenseCostUseCaseProvider =
    Provider<CreateExpenseCostUseCase>((ref) {
  final repository = ref.watch(costRepositoryProvider);
  final validator = ref.watch(costValidatorProvider);
  final idGenerator = ref.watch(uuidGeneratorProvider);
  return CreateExpenseCostUseCase(
    repository: repository,
    validator: validator,
    idGenerator: idGenerator,
  );
});

final updateCostUseCaseProvider = Provider<UpdateCostUseCase>((ref) {
  final repository = ref.watch(costRepositoryProvider);
  final validator = ref.watch(costValidatorProvider);
  return UpdateCostUseCase(
    repository: repository,
    validator: validator,
  );
});

final getCostsUseCaseProvider = Provider<GetCostsUseCase>((ref) {
  final repository = ref.watch(costRepositoryProvider);
  return GetCostsUseCase(repository: repository);
});

final deleteCostUseCaseProvider = Provider<DeleteCostUseCase>((ref) {
  final repository = ref.watch(costRepositoryProvider);
  return DeleteCostUseCase(repository: repository);
});
