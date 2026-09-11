import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/analytics/application/state/analytics_period_notifier.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/analytics/presentation/extensions/analytics_period_label_extension.dart';
import 'package:flutter/material.dart';

/// Navegação entre períodos, numa linha só.
///
/// O segmentado de semana/mês saiu daqui pra barra superior
/// ([PeriodPresetButton]): as duas linhas juntas comiam quase 100px
/// antes do conteúdo, somadas à AppBar e à TabBar.
class PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod period;
  final AnalyticsPeriodNotifier notifier;

  const PeriodSelector({
    super.key,
    required this.period,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: notifier.goToPrevious,
          tooltip: 'Período anterior',
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            period.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.tabular,
          ),
        ),
        IconButton(
          onPressed: notifier.goToNext,
          tooltip: 'Próximo período',
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

/// Troca o recorte (semana/mês) a partir da barra superior.
class PeriodPresetButton extends StatelessWidget {
  final AnalyticsPeriod period;
  final AnalyticsPeriodNotifier notifier;

  const PeriodPresetButton({
    super.key,
    required this.period,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AnalyticsPeriodPreset>(
      initialValue: period.preset,
      onSelected: notifier.setPreset,
      tooltip: 'Trocar recorte',
      itemBuilder: (context) => [
        for (final preset in [
          AnalyticsPeriodPreset.week,
          AnalyticsPeriodPreset.month,
        ])
          PopupMenuItem(value: preset, child: Text(preset.label)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Chip(
          label: Text(period.preset.label),
          avatar: const Icon(Icons.expand_more, size: 18),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
