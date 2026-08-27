import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/dialogs/delete_cost_dialog.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CostListView extends ConsumerStatefulWidget {
  final List<CostEntity> costs;
  final CostCategory category;

  const CostListView({
    super.key,
    required this.costs,
    required this.category,
  });

  @override
  ConsumerState<CostListView> createState() => _CostListViewState();
}

class _CostListViewState extends ConsumerState<CostListView> {
  // Mesmo motivo do ShiftsListView: remove da tela antes do delete no
  // banco confirmar, pra o Dismissible não sobrar na árvore já dispensado.
  final _hiddenIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final filtered = widget.costs
        .where((cost) => cost.category == widget.category && !_hiddenIds.contains(cost.id))
        .toList();

    if (filtered.isEmpty) {
      return Center(child: Text(_emptyMessage));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final cost = filtered[i];

        return Dismissible(
          key: ValueKey(cost.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          confirmDismiss: (_) => DeleteCostDialog.show(context),
          onDismissed: (_) {
            setState(() => _hiddenIds.add(cost.id));
            ref.read(costNotifierProvider.notifier).deleteCost(cost.id);
          },
          child: CostListTile(
            cost: cost,
            onTap: () => _navigateToEdit(context, cost),
          ),
        );
      },
    );
  }

  void _navigateToEdit(BuildContext context, CostEntity cost) {
    final route = switch (cost) {
      FuelCostEntity() => '/costs/fuel/edit',
      MaintenanceCostEntity() => '/costs/maintenance/edit',
      ExpenseCostEntity() => '/costs/expense/edit',
    };
    context.push(route, extra: cost);
  }

  String get _emptyMessage {
    return switch (widget.category) {
      CostCategory.fuel => 'Nenhum abastecimento lançado.',
      CostCategory.maintenance => 'Nenhuma manutenção lançada.',
      CostCategory.expense => 'Nenhuma despesa lançada.',
    };
  }
}