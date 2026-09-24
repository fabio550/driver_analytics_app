import 'package:driver_analytics_app/core/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/core/presentation/providers/analytics_period_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instância independente do mesmo seletor de período usado em Análises —
/// trocar o recorte em Lançamentos não deve mexer no período que o
/// usuário já tinha escolhido lá, e vice-versa.
final entriesPeriodNotifierProvider =
    NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(
  AnalyticsPeriodNotifier.new,
);
