import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:flutter/material.dart';

class CostCategoryIcon extends StatelessWidget {
  final CostCategory category;
  final double size;

  const CostCategoryIcon({
    super.key,
    required this.category,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (category) {
      CostCategory.fuel => Icons.local_gas_station,
      CostCategory.maintenance => Icons.build,
      CostCategory.expense => Icons.receipt_long,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.55, color: colorScheme.onPrimaryContainer),
    );
  }
}
