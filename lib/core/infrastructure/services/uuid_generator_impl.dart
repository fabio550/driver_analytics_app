import 'package:uuid/uuid.dart';
import 'package:driver_analytics_app/core/domain/services/id_generator.dart';

class UuidGeneratorImpl implements IdGenerator {
  final Uuid _uuid;

  const UuidGeneratorImpl(this._uuid);

  @override
  String generate() {
    return _uuid.v4();
  }
}
