import 'package:driver_analytics_app/core/presentation/pages/app_shell_page.dart';
import 'package:driver_analytics_app/core/presentation/pages/entries_page.dart';
import 'package:driver_analytics_app/core/presentation/pages/home_page.dart';
import 'package:driver_analytics_app/features/analytics/presentation/pages/analytics_page.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/presentation/pages/expense_cost_create_page.dart';
import 'package:driver_analytics_app/features/cost/presentation/pages/fuel_cost_create_page.dart';
import 'package:driver_analytics_app/features/cost/presentation/pages/maintenance_cost_create_page.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/presentation/pages/adjustment_earning_create_page.dart';
import 'package:driver_analytics_app/features/earning/presentation/pages/promotion_earning_create_page.dart';
import 'package:driver_analytics_app/features/earning/presentation/pages/ride_earning_create_page.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/active_shift_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shift_create_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shift_summary_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shifts_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// As quatro abas. Formulários e a jornada em andamento ficam fora da
/// casca de propósito: são telas de foco, sobem por cima da barra.
final routes = [
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShellPage(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/shifts',
            builder: (context, state) => const ShiftsPage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/entries',
            builder: (context, state) => const EntriesPage(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/shifts/create',
    builder: (context, state) => const ShiftCreatePage(),
  ),
  GoRoute(
    path: '/shifts/edit',
    builder: (context, state) => ShiftCreatePage(existing: state.extra as ShiftEntity),
  ),
  GoRoute(
    path: '/shifts/active',
    builder: (context, state) => const ActiveShiftPage(),
  ),
  GoRoute(
    path: '/shifts/active/summary',
    builder: (context, state) => const ShiftSummaryPage(),
  ),
  GoRoute(
    path: '/costs/fuel/create',
    builder: (context, state) => const FuelCostCreatePage(),
  ),
  GoRoute(
    path: '/costs/fuel/edit',
    builder: (context, state) => FuelCostCreatePage(existing: state.extra as FuelCostEntity),
  ),
  GoRoute(
    path: '/costs/maintenance/create',
    builder: (context, state) => const MaintenanceCostCreatePage(),
  ),
  GoRoute(
    path: '/costs/maintenance/edit',
    builder: (context, state) =>
        MaintenanceCostCreatePage(existing: state.extra as MaintenanceCostEntity),
  ),
  GoRoute(
    path: '/costs/expense/create',
    builder: (context, state) => const ExpenseCostCreatePage(),
  ),
  GoRoute(
    path: '/costs/expense/edit',
    builder: (context, state) =>
        ExpenseCostCreatePage(existing: state.extra as ExpenseCostEntity),
  ),
  GoRoute(
    path: '/earnings/ride/create',
    builder: (context, state) => const RideEarningCreatePage(),
  ),
  GoRoute(
    path: '/earnings/ride/edit',
    builder: (context, state) => RideEarningCreatePage(existing: state.extra as RideEarningEntity),
  ),
  GoRoute(
    path: '/earnings/promotion/create',
    builder: (context, state) => const PromotionEarningCreatePage(),
  ),
  GoRoute(
    path: '/earnings/adjustment/create',
    builder: (context, state) => const AdjustmentEarningCreatePage(),
  ),
];
