import 'package:driver_analytics_app/features/earning/domain/enums/earning_kind.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';

part 'ride_earning_entity.dart';
part 'promotion_earning_entity.dart';
part 'adjustment_earning_entity.dart';

sealed class EarningEntity {
  final String id;
  final String? shiftId;
  final DateTime occurredAt;
  final String? description;

  const EarningEntity({
    required this.id,
    this.shiftId,
    required this.occurredAt,
    this.description,
  });

  EarningKind get kind;
  double get amount;
}