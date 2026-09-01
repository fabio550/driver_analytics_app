import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/daily_profit_chart.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/period_selector.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/summary_analytics_card.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  @override
  void initState() {
    super.initState();

    // Cada fonte carrega só se ainda ninguém pediu — a página de análise
    // não é dona desses dados, só os consome.
    Future.microtask(() {
      final shiftState = ref.read(shiftNotifierProvider);
      if (shiftState.status == LoadStatus.initial) {
        ref.read(shiftNotifierProvider.notifier).loadShifts();
      }

      final costState = ref.read(costNotifierProvider);
      if (costState.status == LoadStatus.initial) {
        ref.read(costNotifierProvider.notifier).loadCosts();
      }

      final earningState = ref.read(earningNotifierProvider);
      if (earningState.status == LoadStatus.initial) {
        ref.read(earningNotifierProvider.notifier).loadEarnings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shiftStatus = ref.watch(
      shiftNotifierProvider.select((state) => state.status),
    );
    final costStatus = ref.watch(
      costNotifierProvider.select((state) => state.status),
    );
    final earningStatus = ref.watch(
      earningNotifierProvider.select((state) => state.status),
    );

    final statuses = [shiftStatus, costStatus, earningStatus];
    final isLoading = statuses.any(
      (status) => status == LoadStatus.initial || status == LoadStatus.loading,
    );
    final hasError = statuses.any((status) => status == LoadStatus.error);

    final period = ref.watch(analyticsPeriodNotifierProvider);
    final periodNotifier = ref.read(analyticsPeriodNotifierProvider.notifier);
    final summary = ref.watch(summaryAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Análises')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text('Não foi possível carregar as análises.'),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    PeriodSelector(period: period, notifier: periodNotifier),
                    const SizedBox(height: AppSpacing.md),
                    SummaryAnalyticsCard(summary: summary),
                    const SizedBox(height: AppSpacing.md),
                    if (summary.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: Text('Sem jornadas confirmadas no período.'),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: DailyProfitChart(entries: summary.dailyProfits),
                        ),
                      ),
                  ],
                ),
    );
  }
}
