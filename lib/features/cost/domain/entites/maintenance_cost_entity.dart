class MaintenanceCostEntity extends CostEntity {
  final MaintenanceSubcategory subcategory;

  /// Opcional — nem toda manutenção tem o odômetro anotado na hora, mas
  /// quando tem, dá pra alertar "faltam X km pra próxima troca" depois.
  final double? odometerKm;

  const MaintenanceCostEntity({
    required super.id,
    required super.amount,
    required super.date,
    super.description,
    required this.subcategory,
    this.odometerKm,
  });

  @override
  CostCategory get category => CostCategory.maintenance;
}
