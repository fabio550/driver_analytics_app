import 'package:drift/drift.dart';

import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/mappers/shift_mapper.dart';
import 'package:driver_analytics_app/features/shift/infrastructure/database/mappers/shift_pause_mapper.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final AppDatabase _database;
  final ShiftMapper _mapper;
  final ShiftPauseMapper _pauseMapper;

  const ShiftRepositoryImpl({
    required this._database,
    required this._mapper,
    required this._pauseMapper,
  });

  @override
  Future<List<ShiftEntity>> getAll() async {
    final rows = await _database.select(_database.shifts).get();
    return Future.wait(rows.map(_toEntityWithPauses));
  }

  @override
  Future<ShiftEntity?> getById(String id) async {
    final query = _database.select(_database.shifts)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return _toEntityWithPauses(row);
  }

  @override
  Future<void> create(ShiftEntity shift) async {
    await _database.transaction(() async {
      final companion = _mapper.toCompanion(shift);
      await _database.into(_database.shifts).insert(companion);

      for (final pause in shift.pauses) {
        final pauseCompanion = _pauseMapper.toCompanion(pause, shift.id);
        await _database.into(_database.shiftPauses).insert(pauseCompanion);
      }
    });
  }

  @override
  Future<void> update(ShiftEntity shift) async {
    await _database.transaction(() async {
      final companion = _mapper.toCompanion(shift);
      await (_database.update(_database.shifts)
            ..where((table) => table.id.equals(shift.id)))
          .write(companion);

      // Substitui todas as pauses: remove as antigas e reinsere as atuais.
      // Mais simples e seguro que tentar diff (evita pause "fantasma" órfã).
      await (_database.delete(_database.shiftPauses)
            ..where((table) => table.shiftId.equals(shift.id)))
          .go();

      for (final pause in shift.pauses) {
        final pauseCompanion = _pauseMapper.toCompanion(pause, shift.id);
        await _database.into(_database.shiftPauses).insert(pauseCompanion);
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    await _database.transaction(() async {
      await (_database.delete(_database.shiftPauses)
            ..where((table) => table.shiftId.equals(id)))
          .go();
      await (_database.delete(_database.shifts)
            ..where((table) => table.id.equals(id)))
          .go();
    });
  }

  Future<ShiftEntity> _toEntityWithPauses(Shift row) async {
    final pauseRows = await (_database.select(_database.shiftPauses)
          ..where((table) => table.shiftId.equals(row.id)))
        .get();

    final shift = _mapper.fromRow(row);
    return shift.copyWith(
      pauses: pauseRows.map(_pauseMapper.fromRow).toList(),
    );
  }
}
