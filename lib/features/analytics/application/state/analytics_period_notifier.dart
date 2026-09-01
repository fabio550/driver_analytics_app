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

  void goToPrevious() {
    state = state.previous;
  }

  void goToNext() {
    state = state.next;
  }

  /// Troca o tipo de recorte (semana/mês) ancorado em hoje — usado pelo
  /// seletor de período; custom só chega via [setPeriod] com datas explícitas.
  void setPreset(AnalyticsPeriodPreset preset) {
    final now = DateTime.now();
    state = switch (preset) {
      AnalyticsPeriodPreset.week => AnalyticsPeriod.week(now),
      AnalyticsPeriodPreset.month => AnalyticsPeriod.month(now),
      AnalyticsPeriodPreset.custom => state,
    };
  }
}