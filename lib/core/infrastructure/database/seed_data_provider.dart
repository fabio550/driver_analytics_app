import 'package:driver_analytics_app/core/infrastructure/database/seed_data_service.dart';
import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_provider.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_dependency.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_dependency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seedDataServiceProvider = Provider<SeedDataService>((ref) {
  return SeedDataService(
    shiftRepository: ref.watch(shiftRepositoryProvider),
    costRepository: ref.watch(costRepositoryProvider),
    idGenerator: ref.watch(uuidGeneratorProvider),
  );
});
