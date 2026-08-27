import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CostTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const CostTabBar({super.key, required this.controller});

  static const _tabs = [
    Tab(icon: Icon(Icons.local_gas_station, size: 20), text: 'Abastecimento'),
    Tab(icon: Icon(Icons.build, size: 20), text: 'Manutenção'),
    Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Despesa'),
  ];

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabAlignment: TabAlignment.fill,
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      labelStyle: AppTextStyles.tabLabel,
      unselectedLabelStyle: AppTextStyles.caption,
      tabs: _tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
