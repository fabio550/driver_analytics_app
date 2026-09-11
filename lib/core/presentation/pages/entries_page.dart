import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/error_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/dialogs/cost_category_sheet.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_list_view.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_kind.dart';
import 'package:driver_analytics_app/features/earning/presentation/dialogs/earning_kind_sheet.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/earnings_list_view.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _EntriesSegment { earnings, costs }

/// Ganhos e Custos numa aba só. Eram duas telas separadas, com padrões
/// de criação diferentes (FAB que trocava de rótulo por aba de um lado,
/// FAB + sheet do outro) e sem caminho entre elas: pra ir de uma à outra
/// era preciso voltar à Home. São o mesmo trabalho — dinheiro entrando e
/// saindo — então viraram dois segmentos da mesma lista.
class EntriesPage extends ConsumerStatefulWidget {
  const EntriesPage({super.key});

  @override
  ConsumerState<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends ConsumerState<EntriesPage> {
  _EntriesSegment _segment = _EntriesSegment.earnings;
  CostCategory? _costFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadIfNeeded);
  }

  void _loadIfNeeded() {
    if (ref.read(earningNotifierProvider).status == LoadStatus.initial) {
      ref.read(earningNotifierProvider.notifier).loadEarnings();
    }
    if (ref.read(costNotifierProvider).status == LoadStatus.initial) {
      ref.read(costNotifierProvider.notifier).loadCosts();
    }
    if (ref.read(shiftNotifierProvider).status == LoadStatus.initial) {
      ref.read(shiftNotifierProvider.notifier).loadShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
        centerTitle: false,
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SegmentedButton<_EntriesSegment>(
              segments: const [
                ButtonSegment(
                  value: _EntriesSegment.earnings,
                  label: Text('Ganhos'),
                ),
                ButtonSegment(
                  value: _EntriesSegment.costs,
                  label: Text('Custos'),
                ),
              ],
              selected: {_segment},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() => _segment = selection.first);
              },
            ),
          ),
          if (_segment == _EntriesSegment.costs) _costFilters(),
          Expanded(
            child: switch (_segment) {
              _EntriesSegment.earnings => _earnings(),
              _EntriesSegment.costs => _costs(),
            },
          ),
        ],
      ),
    );
  }

  Widget _costFilters() {
    const options = <(String, CostCategory?)>[
      ('Todos', null),
      ('Combustível', CostCategory.fuel),
      ('Manutenção', CostCategory.maintenance),
      ('Despesas', CostCategory.expense),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final (label, category) = options[i];

          return ChoiceChip(
            label: Text(label),
            selected: _costFilter == category,
            onSelected: (_) => setState(() => _costFilter = category),
          );
        },
      ),
    );
  }

  Widget _earnings() {
    final earningState = ref.watch(earningNotifierProvider);
    final shiftState = ref.watch(shiftNotifierProvider);

    if (earningState.status == LoadStatus.error) {
      return ErrorStateView(
        message: 'Seus lançamentos continuam salvos no aparelho. '
            'Tente abrir de novo.',
        onRetry: () => ref.read(earningNotifierProvider.notifier).loadEarnings(),
      );
    }

    final isLoading = earningState.status != LoadStatus.loaded ||
        shiftState.status != LoadStatus.loaded;
    if (isLoading) return const _ListSkeleton();

    return EarningsListView(
      earnings: earningState.earnings,
      shifts: shiftState.shifts,
      onCreate: _openCreateSheet,
      onTapEarning: (earning) {
        final route = switch (earning) {
          RideEarningEntity() => '/earnings/ride/edit',
          PromotionEarningEntity() => '/earnings/promotion/edit',
          AdjustmentEarningEntity() => '/earnings/adjustment/edit',
        };
        context.push(route, extra: earning);
      },
    );
  }

  Widget _costs() {
    final costState = ref.watch(costNotifierProvider);

    if (costState.status == LoadStatus.error) {
      return ErrorStateView(
        message: 'Seus lançamentos continuam salvos no aparelho. '
            'Tente abrir de novo.',
        onRetry: () => ref.read(costNotifierProvider.notifier).loadCosts(),
      );
    }

    if (costState.status != LoadStatus.loaded) return const _ListSkeleton();

    return CostListView(
      costs: costState.costs,
      category: _costFilter,
      onCreate: _openCreateSheet,
    );
  }

  Future<void> _openCreateSheet() async {
    if (_segment == _EntriesSegment.earnings) {
      final kind = await EarningKindSheet.show(context);
      if (kind == null || !mounted) return;

      context.push(switch (kind) {
        EarningKind.ride => '/earnings/ride/create',
        EarningKind.promotion => '/earnings/promotion/create',
        EarningKind.adjustment => '/earnings/adjustment/create',
      });
      return;
    }

    final category = await CostCategorySheet.show(context);
    if (category == null || !mounted) return;

    context.push(switch (category) {
      CostCategory.fuel => '/costs/fuel/create',
      CostCategory.maintenance => '/costs/maintenance/create',
      CostCategory.expense => '/costs/expense/create',
    });
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        96,
      ),
      children: [
        const SkeletonBox(width: 140, height: 14),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 4; i++) ...[
          const SkeletonCard(
            children: [
              SkeletonBox(width: 120, height: 15),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 34),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 34),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
