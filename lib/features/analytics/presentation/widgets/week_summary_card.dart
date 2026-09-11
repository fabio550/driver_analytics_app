import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_semantic_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/summary_analytics.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/revenue_split_bar.dart';
import 'package:flutter/material.dart';

/// O resumo da semana no Início. Consome o mesmo cálculo das Análises,
/// então os dois números nunca divergem.
class WeekSummaryCard extends StatelessWidget {
  final SummaryAnalytics summary;

  const WeekSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semantic = AppSemanticColors.of(context);

    return Card(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lucro líquido',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        summary.netProfit.formattedCurrency,
                        style: textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: semantic.forAmount(summary.netProfit),
                            )
                            .tabular,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  child: Text(
                    '${summary.shiftCount} ${summary.shiftCount == 1 ? 'jornada' : 'jornadas'}',
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)
                        .tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            RevenueSplitBar(revenue: summary.revenue, cost: summary.cost),
            const SizedBox(height: AppSpacing.md),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'R\$/h líquido',
                    value: summary.netEarningsPerHour.formattedCurrencyOrDash,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'R\$/km líquido',
                    value: summary.netEarningsPerKm.formattedCurrencyOrDash,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Margem',
                    value: summary.margin.formattedPercentOrDash,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold).tabular,
        ),
      ],
    );
  }
}
