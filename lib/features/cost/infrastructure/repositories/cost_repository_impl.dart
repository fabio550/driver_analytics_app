import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/domain/repositories/cost_repository.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/mappers/cost_mapper.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/mappers/fuel_cost_mapper.dart';
import 'package:driver_analytics_app/features/cost/infrastructure/database/mappers/maintenance_cost_mapper.dart';

class CostRepositoryImpl implements CostRepository {
  final AppDatabase _database;
  final CostMapper _mapper;
  final FuelCostMapper _fuelMapper;
  final MaintenanceCostMapper _maintenanceMapper;

  const CostRepositoryImpl({
    required this._database,
    required this._mapper,
    required this._fuelMapper,
    required this._maintenanceMapper,
  });

  @override
  Future<List<CostEntity>> getAll() async {
    final rows = await _database.select(_database.costs).get();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<CostEntity?> getById(String id) async {
    final query = _database.select(_database.costs)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<void> create(CostEntity cost) async {
    await _database.transaction(() async {
      await _database.into(_database.costs).insert(_mapper.toCompanion(cost));
      await _insertExtension(cost);
    });
  }

  @override
  Future<void> update(CostEntity cost) async {
    await _database.transaction(() async {
      await (_database.update(_database.costs)
            ..where((t) => t.id.equals(cost.id)))
          .write(_mapper.toCompanion(cost));

      await (_database.delete(_database.fuelCosts)
            ..where((t) => t.costId.equals(cost.id)))
          .go();
      await (_database.delete(_database.maintenanceCosts)
            ..where((t) => t.costId.equals(cost.id)))
          .go();

      await _insertExtension(cost);
    });
  }

  @override
  Future<void> delete(String id) async {
    await _database.transaction(() async {
      await (_database.delete(_database.fuelCosts)
            ..where((t) => t.costId.equals(id)))
          .go();
      await (_database.delete(_database.maintenanceCosts)
            ..where((t) => t.costId.equals(id)))
          .go();
      await (_database.delete(_database.costs)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }

  Future<void> _insertExtension(CostEntity cost) async {
    switch (cost) {
      case FuelCostEntity():
        await _database
            .into(_database.fuelCosts)
            .insert(_fuelMapper.toCompanion(cost));
      case MaintenanceCostEntity():
        await _database
            .into(_database.maintenanceCosts)
            .insert(_maintenanceMapper.toCompanion(cost));
      case ExpenseCostEntity():
        break;
    }
  }

  Future<CostEntity> _toEntity(Cost row) async {
    switch (CostCategory.values.byName(row.category)) {
      case CostCategory.fuel:
        final fuelRow = await (_database.select(_database.fuelCosts)
              ..where((t) => t.costId.equals(row.id)))
            .getSingle();
        return _fuelMapper.fromRows(row, fuelRow);

      case CostCategory.maintenance:
        final maintenanceRow = await (_database.select(
                _database.maintenanceCosts)
              ..where((t) => t.costId.equals(row.id)))
            .getSingle();
        return _maintenanceMapper.fromRows(row, maintenanceRow);

      case CostCategory.expense:
        return _mapper.fromExpenseRow(row);
    }
  }
}
