// ignore_for_file: prefer_initializing_formals

part of 'earning_entity.dart';

class PromotionEarningEntity extends EarningEntity {
  final double _amount;

  const PromotionEarningEntity({
    required super.id,
    super.shiftId,
    required super.occurredAt,
    super.description,
    required double amount,
  }) : _amount = amount;

  @override
  EarningKind get kind => EarningKind.promotion;

  @override
  double get amount => _amount;
}