import 'package:driver_analytics_app/features/cost/application/state/cost_notifier.dart';
import 'package:driver_analytics_app/features/cost/application/state/cost_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final costNotifierProvider = NotifierProvider<CostNotifier, CostState>(
  CostNotifier.new,
);
