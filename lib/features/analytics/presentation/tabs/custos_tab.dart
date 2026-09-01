import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/breakdown_bar_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/ranked_bar_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/stat_grid_card.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/cost_category_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustosTab extends ConsumerWidget {
  const CustosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cost = ref.watch(costAnalyticsProvider);
    final series = AppChartColors.series(Theme.of(context).brightness);

    if (cost.isEmpty) {
      return const Center(child: Text('Sem custos lançados no período.'));
    }

    return ScreenScrollView(
      children: [
        BreakdownBarCard(
          title: 'Para onde foi o dinheiro',
          items: [
            for (var i = 0; i < cost.byCategory.length; i++)
              BreakdownItem(
                label: cost.byCategory[i].category.label,
                amount: cost.byCategory[i].amount,
                color: series[i % series.length],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (cost.fuelEfficiency.kmPerLiter != null ||
            cost.fuelEfficiency.costPerKm != null ||
            cost.fuelEfficiency.costPerLiter != null) ...[
          StatGridCard(
            title: 'Combustível',
            columns: 3,
            entries: [
              StatGridEntry(
                label: 'Consumo',
                value: cost.fuelEfficiency.kmPerLiter != null
                    ? '${cost.fuelEfficiency.kmPerLiter!.toStringAsFixed(1)} km/L'
                    : '—',
              ),
              StatGridEntry(
                label: 'R\$/km',
                value: cost.fuelEfficiency.costPerKm.formattedCurrencyOrDash,
              ),
              StatGridEntry(
                label: 'R\$/litro',
                value: cost.fuelEfficiency.costPerLiter.formattedCurrencyOrDash,
              ),
            ],
            footnote: cost.fuelEfficiency.kmPerLiter == null
                ? 'Consumo precisa de dois abastecimentos de tanque cheio no '
                    'período pra fechar a conta.'
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        RankedBarCard(
          title: 'Maiores lançamentos',
          barColor: series[0],
          items: [
            for (final entry in cost.topEntries)
              RankedItem(
                label: entry.label,
                value: entry.amount,
                displayValue: entry.amount.formattedCurrency,
              ),
          ],
          footnote: cost.topEntries.isEmpty
              ? null
              : 'Os ${cost.topEntries.length} maiores lançamentos do período.',
        ),
      ],
    );
  }
}
