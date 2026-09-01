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
