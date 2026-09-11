import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/empty_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/section_header.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/dialogs/delete_cost_dialog.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lista de custos com cabeçalho de mês. [category] nulo mostra todas as
/// categorias — o filtro virou um chip acima da lista em vez de uma aba,
/// então "todos" passou a ser um estado possível.
class CostListView extends ConsumerStatefulWidget {
  final List<CostEntity> costs;
  final CostCategory? category;
  final VoidCallback? onCreate;

  const CostListView({
    super.key,
    required this.costs,
    required this.category,
    this.onCreate,
  });

  @override
  ConsumerState<CostListView> createState() => _CostListViewState();
}

class _CostListViewState extends ConsumerState<CostListView> {
  // Remove da tela antes do delete no banco confirmar, pra o Dismissible
  // não sobrar na árvore já dispensado.
  final _hiddenIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final filtered = widget.costs
        .where(
          (cost) =>
              (widget.category == null || cost.category == widget.category) &&
              !_hiddenIds.contains(cost.id),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return EmptyStateView(
        icon: Icons.receipt_long_outlined,
        title: _emptyTitle,
        message: 'Custo lançado aqui entra no rateio que vira o R\$/hora '
            'líquido das Análises.',
        action: widget.onCreate == null
            ? null
            : FilledButton.icon(
                onPressed: widget.onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Novo custo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                ),
              ),
      );
    }

    final items = _withMonthHeaders(filtered);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 96),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];

        if (item is _MonthHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: SectionHeader(
              label: item.month.formattedMonthAndYear,
              trailingText: item.total.formattedCurrency,
            ),
          );
        }

        final cost = item as CostEntity;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Dismissible(
            key: ValueKey(cost.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
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
          ),
        );
      },
    );
  }

  List<Object> _withMonthHeaders(List<CostEntity> costs) {
    final items = <Object>[];
    DateTime? currentMonth;

    for (final cost in costs) {
      final month = DateTime(cost.date.year, cost.date.month);

      if (currentMonth == null || month != currentMonth) {
        currentMonth = month;
        final total = costs
            .where((c) => c.date.year == month.year && c.date.month == month.month)
            .fold<double>(0, (sum, c) => sum + c.amount);
        items.add(_MonthHeader(month: month, total: total));
      }

      items.add(cost);
    }

    return items;
  }

  void _navigateToEdit(BuildContext context, CostEntity cost) {
    final route = switch (cost) {
      FuelCostEntity() => '/costs/fuel/edit',
      MaintenanceCostEntity() => '/costs/maintenance/edit',
      ExpenseCostEntity() => '/costs/expense/edit',
    };
    context.push(route, extra: cost);
  }

  String get _emptyTitle {
    return switch (widget.category) {
      CostCategory.fuel => 'Nenhum abastecimento lançado',
      CostCategory.maintenance => 'Nenhuma manutenção lançada',
      CostCategory.expense => 'Nenhuma despesa lançada',
      null => 'Nenhum custo lançado',
    };
  }
}

class _MonthHeader {
  final DateTime month;
  final double total;

  const _MonthHeader({required this.month, required this.total});
}
