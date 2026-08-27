import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';

abstract interface class EarningRepository {
  Future<List<EarningEntity>> getAll();
  Future<EarningEntity?> getById(String id);
  Future<void> create(EarningEntity earning);
  Future<void> update(EarningEntity earning);
  Future<void> delete(String id);
}