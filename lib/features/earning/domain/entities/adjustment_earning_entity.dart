// ignore_for_file: prefer_initializing_formals

part of 'earning_entity.dart';

class AdjustmentEarningEntity extends EarningEntity {
  final double _amount;

  const AdjustmentEarningEntity({
    required super.id,
    super.shiftId,
    required super.occurredAt,
    super.description,
    required double amount,
  }) : _amount = amount;

  @override
  EarningKind get kind => EarningKind.adjustment;

  @override
  double get amount => _amount;
}