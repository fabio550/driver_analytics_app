import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/completeness_banner.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/district_ranking_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/hourly_earnings_chart.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/locked_notice.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/split_card.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/stat_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperacaoTab extends ConsumerWidget {
  const OperacaoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operation = ref.watch(operationAnalyticsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final series = AppChartColors.series(Theme.of(context).brightness);

    if (operation.isEmpty) {
      return const Center(child: Text('Sem jornadas confirmadas no período.'));
    }

    return ScreenScrollView(
      children: [
        CompletenessBanner(completeness: operation.completeness),
        const SizedBox(height: AppSpacing.sm),
        StatGridCard(
          title: 'Tempo',
          columns: 3,
          entries: [
            StatGridEntry(label: 'Total', value: operation.totalTime.formattedHHmm),
            StatGridEntry(label: 'Ativo', value: operation.activeTime.formattedHHmm),
            StatGridEntry(label: 'Pausado', value: operation.pausedTime.formattedHHmm),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!operation.hasDetail)
          const LockedNotice(
            message: 'Produtividade, ociosidade e análise por região aparecem '
                'quando as jornadas do período estiverem completas.',
          )
        else
          _OperationDetail(operation: operation, series: series, colorScheme: colorScheme),
      ],
    );
  }
}

class _OperationDetail extends StatelessWidget {
  final OperationAnalytics operation;
  final List<Color> series;
  final ColorScheme colorScheme;

  const _OperationDetail({
    required this.operation,
    required this.series,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final timeSplit = operation.timeSplit!;
    final distanceSplit = operation.distanceSplit!;
    final pace = operation.pace!;

    final activeMinutes = timeSplit.withPassenger.inMinutes + timeSplit.available.inMinutes;
    final passengerSharePct = activeMinutes > 0
        ? (timeSplit.withPassenger.inMinutes / activeMinutes)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SplitCard(
          title: 'Tempo — onde o turno foi',
          heroValue: timeSplit.withPassenger.formattedHHmm,
          heroQualifier: passengerSharePct != null
              ? 'com passageiro · ${passengerSharePct.formattedPercent} do turno'
              : 'com passageiro',
          entries: [
            SplitEntry(
              label: 'Com passageiro',
              value: timeSplit.withPassenger.inSeconds.toDouble(),
              displayValue: timeSplit.withPassenger.formattedHHmm,
              color: series[0],
            ),
            SplitEntry(
              label: 'Disponível',
              value: timeSplit.available.inSeconds.toDouble(),
              displayValue: timeSplit.available.formattedHHmm,
              color: series[1],
            ),
            SplitEntry(
              label: 'Pausado',
              value: timeSplit.paused.inSeconds.toDouble(),
              displayValue: timeSplit.paused.formattedHHmm,
              color: colorScheme.outlineVariant,
            ),
          ],
          footnote: '"Disponível" é o tempo ligado esperando ou indo buscar — só '
              'existe porque a soma das durações das corridas cobre o turno.',
        ),
        const SizedBox(height: AppSpacing.sm),
        SplitCard(
          title: 'Distância — ${operation.totalDistanceKm.formattedKm} rodados',
          heroValue: distanceSplit.idleKm.formattedKm,
          heroQualifier: distanceSplit.total > 0
              ? 'sem passageiro · ${(distanceSplit.idleKm / distanceSplit.total).formattedPercent}'
              : 'sem passageiro',
          entries: [
            SplitEntry(
              label: 'Com passageiro',
              value: distanceSplit.withPassengerKm,
              displayValue: distanceSplit.withPassengerKm.formattedKm,
              color: series[0],
            ),
            SplitEntry(
              label: 'Sem passageiro',
              value: distanceSplit.idleKm,
              displayValue: distanceSplit.idleKm.formattedKm,
              color: series[1],
            ),
          ],
          footnote: 'Ociosidade de km tende a ser maior que a de tempo — rodar '
              'vazio é mais rápido, sem embarque nem desembarque.',
        ),
        const SizedBox(height: AppSpacing.sm),
        StatGridCard(
          title: 'Ritmo',
          columns: 2,
          entries: [
            StatGridEntry(label: 'Corridas', value: '${pace.rideCount}'),
            StatGridEntry(
              label: 'Por hora ativa',
              value: pace.ridesPerActiveHour?.toStringAsFixed(1) ?? '—',
            ),
            StatGridEntry(
              label: 'Cancelamento',
              value: pace.cancellationRate.formattedPercentOrDash,
            ),
            StatGridEntry(
              label: 'Duração média',
              value: pace.averageRideDuration != null
                  ? '${pace.averageRideDuration!.inMinutes} min'
                  : '—',
            ),
            StatGridEntry(
              label: 'Distância média',
              value: pace.averageRideDistanceKm != null
                  ? '${pace.averageRideDistanceKm!.toStringAsFixed(1)} km'
                  : '—',
            ),
          ],
          footnote: 'Base: ${pace.completedRideCount} corridas concluídas. As '
              '${pace.cancelledRideCount} canceladas entram só no cancelamento.',
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'GANHO POR HORA DO DIA',
                  style: AppTextStyles.eyebrow.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                HourlyEarningsChart(entries: operation.hourlyEarnings!),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DistrictRankingCard(districts: operation.districts!, barColor: series[0]),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 108,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 4),
                Text(
                  'Mapa por zona — etapa posterior',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
