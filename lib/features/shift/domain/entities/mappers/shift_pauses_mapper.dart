import 'package:drift/drift.dart';

import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';

class ShiftPauseMapper {
  const ShiftPauseMapper();

  ShiftPauseEntity fromRow(ShiftPause row) {
    return ShiftPauseEntity(
      id: row.id,
      startTime: row.startTime,
      endTime: row.endTime,
    );
  }

  ShiftPausesCompanion toCompanion(ShiftPauseEntity pause, String shiftId) {
    return ShiftPausesCompanion(
      id: Value(pause.id),
      shiftId: Value(shiftId),
      startTime: Value(pause.startTime),
      endTime: Value(pause.endTime),
    );
  }
}
