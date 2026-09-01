import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/presentation/extensions/revenue_source_label_extension.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/breakdown_bar_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/ranked_bar_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/stat_grid_card.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Receita ≠ Corridas: promoção e ajuste entram na receita mas não são
/// corrida — por isso "de onde veio o dinheiro", não "corridas" (rail
/// item 4 do design de referência).
class ReceitaTab extends ConsumerWidget {
  const ReceitaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue = ref.watch(revenueAnalyticsProvider);
    final series = AppChartColors.series(Theme.of(context).brightness);

    if (revenue.isEmpty) {
      return const Center(child: Text('Sem receita lançada no período.'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        BreakdownBarCard(
          title: 'De onde veio o dinheiro',
          items: [
            for (var i = 0; i < revenue.bySource.length; i++)
              BreakdownItem(
                label: revenue.bySource[i].source.label,
                amount: revenue.bySource[i].amount,
                color: series[i % series.length],
              ),
          ],
          footnote: 'Receita total inclui promoção e ajuste, que não são corrida — '
              'é este total que precisa bater com o valor informado na jornada.',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (revenue.byServiceType.isNotEmpty) ...[
          RankedBarCard(
            title: 'Por tipo de serviço',
            barColor: series[0],
            items: [
              for (final entry in revenue.byServiceType)
                RankedItem(
                  label: entry.serviceType.label,
                  value: entry.amount,
                  displayValue: entry.amount.formattedCurrency,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        StatGridCard(
          title: 'Ticket médio',
          columns: 3,
          entries: [
            StatGridEntry(
              label: 'Por corrida',
              value: revenue.averageTicket.amountPerPaidRide.formattedCurrencyOrDash,
            ),
            StatGridEntry(
              label: 'Remuneradas',
              value: '${revenue.averageTicket.paidRideCount}',
            ),
            StatGridEntry(
              label: 'Efetivadas',
              value: '${revenue.averageTicket.completedRideCount}',
            ),
          ],
          footnote: 'Remuneradas — concluídas mais canceladas com taxa. As '
              'canceladas sem taxa ficam de fora pra não derrubar a média.',
        ),
      ],
    );
  }
}
