import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/analytics/application/state/analytics_period_notifier.dart';
import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/analytics/presentation/extensions/analytics_period_label_extension.dart';
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        // Custom não tem toggle — só chega escolhendo datas específicas,
        // então o segmentado só faz sentido pra semana/mês.
        if (period.preset != AnalyticsPeriodPreset.custom)
          SegmentedButton<AnalyticsPeriodPreset>(
            segments: const [
              ButtonSegment(
                value: AnalyticsPeriodPreset.week,
                label: Text('Semana'),
              ),
              ButtonSegment(
                value: AnalyticsPeriodPreset.month,
                label: Text('Mês'),
              ),
            ],
            selected: {period.preset},
            onSelectionChanged: (selection) {
              notifier.setPreset(selection.first);
            },
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: notifier.goToPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              period.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              onPressed: notifier.goToNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}
