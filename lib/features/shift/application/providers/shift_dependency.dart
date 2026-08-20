import 'package:driver_analytics_app/core/infrastructure/database/app_database_provider.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/shift_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_provider.dart';

import 'package:driver_analytics_app/features/shift/application/use_cases/create_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/delete_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/get_shifts_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/update_shift_use_case.dart';

import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/domain/validators/shift_validator.dart';

import 'package:driver_analytics_app/features/shift/infrastructure/database/mappers/shift_mapper.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/mappers/shift_pause_mapper.dart';

final shiftMapperProvider = Provider<ShiftMapper>((ref) {
  return const ShiftMapper();
});

final shiftPauseMapperProvider = Provider<ShiftPauseMapper>((ref) {
  return const ShiftPauseMapper();
});

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final mapper = ref.watch(shiftMapperProvider);
  final pauseMapper = ref.watch(shiftPauseMapperProvider);
  return ShiftRepositoryImpl(
    database: database,
    mapper: mapper,
    pauseMapper: pauseMapper,
  );
});

final shiftValidatorProvider = Provider<ShiftValidator>((ref) {
  return const ShiftValidator();
});

final createShiftUseCaseProvider = Provider<CreateShiftUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  final validator = ref.watch(shiftValidatorProvider);
  final idGenerator = ref.watch(uuidGeneratorProvider);
  return CreateShiftUseCase(
    repository: repository,
    validator: validator,
    idGenerator: idGenerator,
  );
});

final updateShiftUseCaseProvider = Provider<UpdateShiftUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  final validator = ref.watch(shiftValidatorProvider);
  return UpdateShiftUseCase(
    repository: repository,
    validator: validator,
  );
});

final getShiftsUseCaseProvider = Provider<GetShiftsUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  return GetShiftsUseCase(
    repository: repository,
  );
});

final deleteShiftUseCaseProvider = Provider<DeleteShiftUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  return DeleteShiftUseCase(
    repository: repository,
  );
});
