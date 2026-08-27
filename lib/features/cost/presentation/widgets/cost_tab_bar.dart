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
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      tabs: _tabs,
    );
  }

  // Altura padrão do Material pra tabs com ícone + texto.
  @override
  Size get preferredSize => const Size.fromHeight(72);
}
