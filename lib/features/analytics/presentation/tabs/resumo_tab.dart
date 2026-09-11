import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/empty_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/daily_profit_chart.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/hero_profit_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/kpi_card.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
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
      return const EmptyStateView(
        icon: Icons.insights_outlined,
        title: 'Nada no período',
        message: 'Finalize uma jornada ou escolha outro período pra ver o '
            'resumo aqui.',
      );
    }

    return ScreenScrollView(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroProfitCard(summary: summary),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'R\$/h líquido',
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
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiCard(
                label: 'Margem',
                value: summary.margin.formattedPercentOrDash,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      'LUCRO POR DIA',
                      style: AppTextStyles.eyebrow.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const _ChartLegend(),
                  ],
                ),
                const SizedBox(height: AppSpacing.fieldPadding),
                DailyProfitChart(entries: summary.dailyProfits),
                if (summary.dailyProfits.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.fieldPadding),
                  Divider(color: colorScheme.outlineVariant, height: 1),
                  const SizedBox(height: AppSpacing.fieldPadding),
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

/// Duas cores, dois sentidos — a posição em relação à linha do zero já
/// separa lucro de prejuízo, mas a legenda é o canal de identidade que
/// não depende de enxergar cor.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _LegendItem(color: AppChartColors.profit, label: 'lucro'),
        SizedBox(width: 10),
        _LegendItem(color: AppChartColors.loss, label: 'prejuízo'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final best = dailyProfits.reduce((a, b) => a.netProfit > b.netProfit ? a : b);
    final average =
        dailyProfits.fold<double>(0, (t, e) => t + e.netProfit) / dailyProfits.length;

    final bestDay = '${best.date.day.toString().padLeft(2, '0')}/'
        '${best.date.month.toString().padLeft(2, '0')}';

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _Footnote(label: 'Melhor $bestDay', value: best.netProfit.formattedCurrency),
        _Footnote(label: 'Média', value: average.formattedCurrency),
      ],
    );
  }
}

class _Footnote extends StatelessWidget {
  final String label;
  final String value;

  const _Footnote({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant)
              .tabular,
        ),
        Text(
          value,
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700)
              .tabular,
        ),
      ],
    );
  }
}
