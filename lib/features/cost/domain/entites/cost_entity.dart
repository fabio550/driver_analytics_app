sealed class CostEntity {
  final String id;
  final double amount;
  final DateTime date;
  final String? description;

  const CostEntity({
    required this.id,
    required this.amount,
    required this.date,
    this.description,
  });

  CostCategory get category;
}
