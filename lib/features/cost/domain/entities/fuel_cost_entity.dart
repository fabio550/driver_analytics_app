part of 'cost_entity.dart';

class FuelCostEntity extends CostEntity {
  final FuelSubcategory subcategory;
  final double odometerKm;

  /// Litros pra combustível líquido, kWh pra energia — a unidade é
  /// implícita pela subcategoria (ver [quantityUnit]).
  final double quantity;

  final bool isFullTank;
  final bool previousFillUpMissing;

  const FuelCostEntity({
    required super.id,
    required super.amount,
    required super.date,
    super.description,
    required this.subcategory,
    required this.odometerKm,
    required this.quantity,
    this.isFullTank = false,
    this.previousFillUpMissing = false,
  });

  @override
  CostCategory get category => CostCategory.fuel;

  String get quantityUnit =>
      subcategory == FuelSubcategory.energy ? 'kWh' : 'L';

  double? get pricePerUnit => quantity > 0 ? amount / quantity : null;
}
