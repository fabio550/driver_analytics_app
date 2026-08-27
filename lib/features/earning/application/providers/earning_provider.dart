import 'package:driver_analytics_app/features/earning/application/state/earning_notifier.dart';
import 'package:driver_analytics_app/features/earning/application/state/earning_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final earningNotifierProvider = NotifierProvider<EarningNotifier, EarningState>(
  EarningNotifier.new,
);