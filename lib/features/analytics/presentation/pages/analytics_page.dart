import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/error_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/analytics/presentation/tabs/costs_tab.dart';
import 'package:driver_analytics_app/features/analytics/presentation/tabs/operacao_tab.dart';
import 'package:driver_analytics_app/features/analytics/presentation/tabs/receita_tab.dart';
import 'package:driver_analytics_app/features/analytics/presentation/tabs/resumo_tab.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/period_selector.dart';
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

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    Tab(text: 'Resumo'),
    Tab(text: 'Operação'),
    Tab(text: 'Receita'),
    Tab(text: 'Custos'),
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Cada fonte carrega só se ainda ninguém pediu — a página de análise
    // não é dona desses dados, só os consome.
    Future.microtask(() {
      if (ref.read(shiftNotifierProvider).status == LoadStatus.initial) {
        ref.read(shiftNotifierProvider.notifier).loadShifts();
      }
      if (ref.read(costNotifierProvider).status == LoadStatus.initial) {
        ref.read(costNotifierProvider.notifier).loadCosts();
      }
      if (ref.read(earningNotifierProvider).status == LoadStatus.initial) {
        ref.read(earningNotifierProvider.notifier).loadEarnings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await Future.wait([
      ref.read(shiftNotifierProvider.notifier).loadShifts(),
      ref.read(costNotifierProvider.notifier).loadCosts(),
      ref.read(earningNotifierProvider.notifier).loadEarnings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ref.watch(shiftNotifierProvider.select((state) => state.status)),
      ref.watch(costNotifierProvider.select((state) => state.status)),
      ref.watch(earningNotifierProvider.select((state) => state.status)),
    ];
    final isLoading = statuses.any(
      (status) => status == LoadStatus.initial || status == LoadStatus.loading,
    );
    final hasError = statuses.any((status) => status == LoadStatus.error);

    final period = ref.watch(analyticsPeriodNotifierProvider);
    final periodNotifier = ref.read(analyticsPeriodNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises'),
        centerTitle: false,
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
        actions: [
          PeriodPresetButton(period: period, notifier: periodNotifier),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Column(
            children: [
              PeriodSelector(period: period, notifier: periodNotifier),
              TabBar(
                controller: _tabController,
                tabAlignment: TabAlignment.fill,
                labelStyle: AppTextStyles.tabLabel,
                unselectedLabelStyle: AppTextStyles.caption,
                tabs: _tabs,
              ),
            ],
          ),
        ),
      ),
      body: switch ((isLoading, hasError)) {
        (true, _) => const _AnalyticsSkeleton(),
        (_, true) => ErrorStateView(
            message: 'Seus dados continuam salvos no aparelho. '
                'Tente abrir de novo.',
            onRetry: _reload,
          ),
        _ => TabBarView(
            controller: _tabController,
            children: const [
              ResumoTab(),
              OperacaoTab(),
              ReceitaTab(),
              CostsTab(),
            ],
          ),
      },
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SkeletonCard(
          children: [
            SkeletonBox(width: 96, height: 13),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(width: 220, height: 40),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(width: 160, height: 12),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 10),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              const Expanded(child: SkeletonBox(height: 62, radius: 12)),
              if (i < 2) const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonCard(
          children: [
            SkeletonBox(width: 104, height: 12),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 150),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 12),
          ],
        ),
      ],
    );
  }
}
