import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_list_view.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CostsPage extends ConsumerStatefulWidget {
  const CostsPage({super.key});

  @override
  ConsumerState<CostsPage> createState() => _CostsPageState();
}

class _CostsPageState extends ConsumerState<CostsPage>
    with SingleTickerProviderStateMixin {
  static const _categories = [
    CostCategory.fuel,
    CostCategory.maintenance,
    CostCategory.expense,
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    // Reconstrói só pra atualizar o rótulo/rota do FAB quando a aba muda.
    _tabController.addListener(() => setState(() {}));

    Future.microtask(() {
      ref.read(costNotifierProvider.notifier).loadCosts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  CostCategory get _activeCategory => _categories[_tabController.index];

  String get _fabLabel {
    return switch (_activeCategory) {
      CostCategory.fuel => 'Novo abastecimento',
      CostCategory.maintenance => 'Nova manutenção',
      CostCategory.expense => 'Nova despesa',
    };
  }

  void _createForActiveTab() {
    final route = switch (_activeCategory) {
      CostCategory.fuel => '/costs/fuel/create',
      CostCategory.maintenance => '/costs/maintenance/create',
      CostCategory.expense => '/costs/expense/create',
    };
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(costNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custos'),
        bottom: CostTabBar(controller: _tabController),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createForActiveTab,
        icon: const Icon(Icons.add),
        label: Text(_fabLabel),
      ),
      body: switch (state.status) {
        LoadStatus.initial ||
        LoadStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        LoadStatus.loaded => TabBarView(
            controller: _tabController,
            children: [
              for (final category in _categories)
                CostListView(costs: state.costs, category: category),
            ],
          ),
        LoadStatus.error => const Center(
            child: Text('Não foi possível carregar os custos.'),
          ),
      },
    );
  }
}