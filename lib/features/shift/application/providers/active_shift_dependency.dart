import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_dependency.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/confirm_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/finish_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/pause_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/resume_shift_use_case.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/start_shift_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startShiftUseCaseProvider = Provider<StartShiftUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  final validator = ref.watch(shiftValidatorProvider);
  final idGenerator = ref.watch(uuidGeneratorProvider);
  return StartShiftUseCase(
    repository: repository,
    validator: validator,
    idGenerator: idGenerator,
  );
});

final pauseShiftUseCaseProvider = Provider<PauseShiftUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  final validator = ref.watch(shiftValidatorProvider);
  final idGenerator = ref.watch(uuidGeneratorProvider);
  return PauseShiftUseCase(
    repository: repository,
    validator: validator,
    idGenerator: idGenerator,
  );
});

final resumeShiftUseCaseProvider = Provider<ResumeShiftUseCase>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  final validator = ref.watch(shiftValidatorProvider);
  return ResumeShiftUseCase(
    repository: repository,
    validator: validator,
  );
});
