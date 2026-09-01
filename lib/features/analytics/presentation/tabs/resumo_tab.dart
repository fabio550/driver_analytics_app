import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/daily_profit_chart.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/hero_profit_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Sobrou quanto?" — o lucro líquido é o número herói e só aparece aqui
/// (ver rail item 1 do design de referência).
class ResumoTab extends ConsumerWidget {
  const ResumoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(summaryAnalyticsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (summary.isEmpty) {
      return const Center(child: Text('Sem jornadas confirmadas no período.'));
    }

    return ScreenScrollView(
      children: [
        HeroProfitCard(
          netProfit: summary.netProfit,
          subtitle: '${summary.shiftCount} jornadas',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: KpiCard(label: 'Ganho bruto', value: summary.revenue.formattedCurrency)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: KpiCard(label: 'Custos', value: summary.cost.formattedCurrency)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiCard(label: 'Margem', value: summary.margin.formattedPercentOrDash),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'R\$/hora líquido',
                value: summary.netEarningsPerHour.formattedCurrencyOrDash,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiCard(
                label: 'R\$/km líquido',
                value: summary.netEarningsPerKm.formattedCurrencyOrDash,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'LUCRO POR DIA',
                  style: AppTextStyles.eyebrow.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                DailyProfitChart(entries: summary.dailyProfits),
                if (summary.dailyProfits.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Divider(color: colorScheme.outlineVariant, height: 1),
                  const SizedBox(height: AppSpacing.xs),
                  _DailyProfitFootnote(dailyProfits: summary.dailyProfits),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyProfitFootnote extends StatelessWidget {
  final List<DailyProfitEntry> dailyProfits;

  const _DailyProfitFootnote({required this.dailyProfits});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final best = dailyProfits.reduce((a, b) => a.netProfit > b.netProfit ? a : b);
    final average =
        dailyProfits.fold<double>(0, (t, e) => t + e.netProfit) / dailyProfits.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Melhor: ${best.netProfit.formattedCurrency}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          'Média ${average.formattedCurrency}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
