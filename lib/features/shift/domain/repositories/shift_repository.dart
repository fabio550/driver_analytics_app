import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';

abstract interface class ShiftRepository {
  Future<List<ShiftEntity>> getAll();

  Future<ShiftEntity?> getById(String id);

  Future<void> create(ShiftEntity account);

  Future<void> update(ShiftEntity account);

  Future<void> delete(String id);
}
