import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';

abstract interface class CostRepository {
  Future<List<CostEntity>> getAll();
  Future<CostEntity?> getById(String id);
  Future<void> create(CostEntity cost);
  Future<void> update(CostEntity cost);
  Future<void> delete(String id);
}
