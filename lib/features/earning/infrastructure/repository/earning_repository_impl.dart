// ignore_for_file: prefer_initializing_formals

import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_kind.dart';
import 'package:driver_analytics_app/features/earning/domain/repositories/earning_repository.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/mappers/earning_mapper.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/database/mappers/ride_earning_mapper.dart';

class EarningRepositoryImpl implements EarningRepository {
  final AppDatabase _database;
  final EarningMapper _mapper;
  final RideEarningMapper _rideMapper;

  const EarningRepositoryImpl({
    required AppDatabase database,
    required EarningMapper mapper,
    required RideEarningMapper rideMapper,
  })  : _database = database,
        _mapper = mapper,
        _rideMapper = rideMapper;

  @override
  Future<List<EarningEntity>> getAll() async {
    final rows = await _database.select(_database.earnings).get();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<EarningEntity?> getById(String id) async {
    final query = _database.select(_database.earnings)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row);
  }

  @override
  Future<void> create(EarningEntity earning) async {
    await _database.transaction(() async {
      await _database.into(_database.earnings).insert(_mapper.toCompanion(earning));
      if (earning is RideEarningEntity) {
        await _database.into(_database.rideEarnings).insert(_rideMapper.toCompanion(earning));
      }
    });
  }

  @override
  Future<void> update(EarningEntity earning) async {
    await _database.transaction(() async {
      await (_database.update(_database.earnings)
            ..where((t) => t.id.equals(earning.id)))
          .write(_mapper.toCompanion(earning));

      await (_database.delete(_database.rideEarnings)
            ..where((t) => t.earningId.equals(earning.id)))
          .go();

      if (earning is RideEarningEntity) {
        await _database.into(_database.rideEarnings).insert(_rideMapper.toCompanion(earning));
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    await _database.transaction(() async {
      await (_database.delete(_database.rideEarnings)
            ..where((t) => t.earningId.equals(id)))
          .go();
      await (_database.delete(_database.earnings)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }

  Future<EarningEntity> _toEntity(Earning row) async {
    switch (EarningKind.values.byName(row.kind)) {
      case EarningKind.ride:
        final rideRow = await (_database.select(_database.rideEarnings)
              ..where((t) => t.earningId.equals(row.id)))
            .getSingle();
        return _rideMapper.fromRows(row, rideRow);
      case EarningKind.promotion:
        return _mapper.fromPromotionRow(row);
      case EarningKind.adjustment:
        return _mapper.fromAdjustmentRow(row);
    }
  }
}