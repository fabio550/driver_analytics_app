import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/summary_analytics.dart';
import 'package:flutter/material.dart';

class SummaryAnalyticsCard extends StatelessWidget {
  final SummaryAnalytics summary;

  const SummaryAnalyticsCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Receita',
                    value: summary.revenue.formattedCurrency,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'Custo',
                    value: summary.cost.formattedCurrency,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Lucro líquido',
                    value: summary.netProfit.formattedCurrency,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'Margem',
                    value: summary.margin.formattedPercentOrDash,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'R\$/hora',
                    value: summary.netEarningsPerHour.formattedCurrencyOrDash,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'R\$/km',
                    value: summary.netEarningsPerKm.formattedCurrencyOrDash,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${summary.shiftCount} jornadas · '
              '${summary.workedTime.formattedHHmm} trabalhadas · '
              '${summary.distanceKm.formattedKm}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
