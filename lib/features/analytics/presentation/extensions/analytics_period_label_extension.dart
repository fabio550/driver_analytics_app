import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';

extension AnalyticsPeriodLabel on AnalyticsPeriod {
  static const _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  /// Rótulo do período pro cabeçalho do seletor — mês por extenso pro
  /// recorte mensal, intervalo de datas pros demais.
  String get label {
    if (preset == AnalyticsPeriodPreset.month) {
      return '${_months[start.month - 1]} ${start.year}';
    }

    final lastDay = end.subtract(const Duration(days: 1));
    return '${start.formattedDDMMYYYY} - ${lastDay.formattedDDMMYYYY}';
  }
}

extension AnalyticsPeriodPresetLabel on AnalyticsPeriodPreset {
  String get label {
    return switch (this) {
      AnalyticsPeriodPreset.week => 'Semana',
      AnalyticsPeriodPreset.month => 'Mês',
      AnalyticsPeriodPreset.custom => 'Personalizado',
    };
  }
}

extension AnalyticsPeriodAverageLabel on AnalyticsPeriod {
  /// Nome da média do próprio período no rodapé do gráfico.
  String get averageLabel {
    return switch (preset) {
      AnalyticsPeriodPreset.week => 'Média da semana',
      AnalyticsPeriodPreset.month => 'Média do mês',
      AnalyticsPeriodPreset.custom => 'Média do período',
    };
  }

  /// Nome da média do recorte que contém este ([AnalyticsPeriod.enclosing]).
  /// Nulo quando não há comparação possível.
  String? get enclosingAverageLabel {
    return switch (preset) {
      AnalyticsPeriodPreset.week => 'Média do mês',
      AnalyticsPeriodPreset.month => 'Média do ano',
      AnalyticsPeriodPreset.custom => null,
    };
  }
}
