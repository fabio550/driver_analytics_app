import 'package:drift/drift.dart';
import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';

class ShiftMapper {
  const ShiftMapper();

  ShiftEntity fromRow(Shift row) {
    return ShiftEntity(
      id: row.id,
      initialKm: row.initialKm,
      finalKm: row.finalKm,
      earnings: row.earnings,
      startTime: row.startTime,
      endTime: row.endTime,
      status: ShiftStatus.values.byName(row.status),
    );
  }

  ShiftsCompanion toCompanion(ShiftEntity shift) {
    return ShiftsCompanion(
      id: Value(shift.id),
      initialKm: Value(shift.initialKm),
      finalKm: Value(shift.finalKm),
      earnings: Value(shift.earnings),
      startTime: Value(shift.startTime),
      endTime: Value(shift.endTime),
      status: Value(shift.status.name),
    );
  }
}
