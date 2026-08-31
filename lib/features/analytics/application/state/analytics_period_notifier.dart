import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() {
    return AnalyticsPeriod.month(DateTime.now());
  }

  void setPeriod(AnalyticsPeriod period) {
    state = period;
  }
}