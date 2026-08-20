import 'package:driver_analytics_app/core/presentation/pages/home_page.dart';
import 'package:driver_analytics_app/features/shift/presentation/pages/shifts_page.dart';
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
];