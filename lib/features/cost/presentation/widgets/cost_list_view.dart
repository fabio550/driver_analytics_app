import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_list_tile.dart';
import 'package:flutter/material.dart';

class CostListView extends StatelessWidget {
  final List<CostEntity> costs;
  final CostCategory category;

  const CostListView({
    super.key,
    required this.costs,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = costs.where((cost) => cost.category == category).toList();

    if (filtered.isEmpty) {
      return Center(child: Text(_emptyMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: filtered.length,
      itemBuilder: (context, i) => CostListTile(cost: filtered[i]),
    );
  }

  String get _emptyMessage {
    return switch (category) {
      CostCategory.fuel => 'Nenhum abastecimento lançado.',
      CostCategory.maintenance => 'Nenhuma manutenção lançada.',
      CostCategory.expense => 'Nenhuma despesa lançada.',
    };
  }
}
