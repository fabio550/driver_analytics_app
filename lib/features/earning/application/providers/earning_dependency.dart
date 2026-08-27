import 'package:driver_analytics_app/core/infrastructure/database/app_database_provider.dart';
import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_provider.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_adjustment_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_promotion_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/create_ride_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/delete_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/get_earnings_use_case.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/update_earning_use_case.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/domain/validators/earning_validator.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/mappers/earning_mapper.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/mappers/ride_earning_mapper.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/repository/earning_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final earningMapperProvider = Provider<EarningMapper>((ref) {
  return const EarningMapper();
});

final rideEarningMapperProvider = Provider<RideEarningMapper>((ref) {
  return const RideEarningMapper();
});

final earningRepositoryProvider = Provider<EarningRepository>((ref) {
  return EarningRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    mapper: ref.watch(earningMapperProvider),
    rideMapper: ref.watch(rideEarningMapperProvider),
  );
});

final earningValidatorProvider = Provider<EarningValidator>((ref) {
  return const EarningValidator();
});

final createRideEarningUseCaseProvider = Provider<CreateRideEarningUseCase>((ref) {
  return CreateRideEarningUseCase(
    repository: ref.watch(earningRepositoryProvider),
    validator: ref.watch(earningValidatorProvider),
    idGenerator: ref.watch(uuidGeneratorProvider),
  );
});

final createPromotionEarningUseCaseProvider = Provider<CreatePromotionEarningUseCase>((ref) {
  return CreatePromotionEarningUseCase(
    repository: ref.watch(earningRepositoryProvider),
    validator: ref.watch(earningValidatorProvider),
    idGenerator: ref.watch(uuidGeneratorProvider),
  );
});

final createAdjustmentEarningUseCaseProvider = Provider<CreateAdjustmentEarningUseCase>((ref) {
  return CreateAdjustmentEarningUseCase(
    repository: ref.watch(earningRepositoryProvider),
    validator: ref.watch(earningValidatorProvider),
    idGenerator: ref.watch(uuidGeneratorProvider),
  );
});

final updateEarningUseCaseProvider = Provider<UpdateEarningUseCase>((ref) {
  return UpdateEarningUseCase(
    repository: ref.watch(earningRepositoryProvider),
    validator: ref.watch(earningValidatorProvider),
  );
});

final getEarningsUseCaseProvider = Provider<GetEarningsUseCase>((ref) {
  return GetEarningsUseCase(repository: ref.watch(earningRepositoryProvider));
});

final deleteEarningUseCaseProvider = Provider<DeleteEarningUseCase>((ref) {
  return DeleteEarningUseCase(repository: ref.watch(earningRepositoryProvider));
});