import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:driver_analytics_app/core/domain/services/id_generator.dart';
import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_impl.dart';

final uuidGeneratorProvider = Provider<IdGenerator>((ref) {
  return const UuidGeneratorImpl(Uuid());
});
