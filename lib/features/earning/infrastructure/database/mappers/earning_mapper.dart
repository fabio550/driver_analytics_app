import 'package:drift/drift.dart';
import 'package:driver_analytics_app/core/infrastructure/database/app_database.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';

class EarningMapper {
  const EarningMapper();

  PromotionEarningEntity fromPromotionRow(Earning row) {
    return PromotionEarningEntity(
      id: row.id,
      shiftId: row.shiftId,
      occurredAt: row.occurredAt,
      description: row.description,
      amount: row.amount!,
    );
  }

  AdjustmentEarningEntity fromAdjustmentRow(Earning row) {
    return AdjustmentEarningEntity(
      id: row.id,
      shiftId: row.shiftId,
      occurredAt: row.occurredAt,
      description: row.description,
      amount: row.amount!,
    );
  }

  EarningsCompanion toCompanion(EarningEntity earning) {
    return EarningsCompanion(
      id: Value(earning.id),
      shiftId: Value(earning.shiftId),
      occurredAt: Value(earning.occurredAt),
      kind: Value(earning.kind.name),
      amount: Value(_storedAmount(earning)),
      description: Value(earning.description),
    );
  }

  double? _storedAmount(EarningEntity earning) {
    return switch (earning) {
      RideEarningEntity() => null,
      PromotionEarningEntity(:final amount) => amount,
      AdjustmentEarningEntity(:final amount) => amount,
    };
  }
}