import 'package:driver_analytics_app/core/presentation/pages/home_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shift_create_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shifts_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/active_shift_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shift_summary_page.dart';
import 'package:go_router/go_router.dart';

final routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: '/shifts',
    builder: (context, state) => const ShiftsPage(),
  ),
  GoRoute(
    path: '/shifts/create',
    builder: (context, state) => const ShiftCreatePage(),
  ),
  GoRoute(
    path: '/shifts/active',
    builder: (context, state) => const ActiveShiftPage(),
  ),
  GoRoute(
    path: '/shifts/active/summary',
    builder: (context, state) => const ShiftSummaryPage(),
  ),
];
