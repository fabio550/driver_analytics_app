import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Casca das quatro abas. Antes a Home era um menu de quatro botões e
/// toda tela empilhava em cima dela: ir de Custos pra Ganhos exigia
/// voltar ao início, e reabrir o app no meio de uma jornada zerava a
/// pilha (era por isso que a ShiftsPage carregava um botão de voltar
/// chumbado no código). Agora cada aba guarda a própria pilha.
class AppShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellPage({super.key, required this.navigationShell});

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Início',
    ),
    NavigationDestination(
      icon: Icon(Icons.directions_car_outlined),
      selectedIcon: Icon(Icons.directions_car),
      label: 'Jornadas',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Lançamentos',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Análises',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _destinations,
        // Tocar de novo na aba já aberta volta ela pro topo da própria
        // pilha, que é o que o usuário espera de uma barra de abas.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
