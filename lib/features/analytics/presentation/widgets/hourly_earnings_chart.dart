import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:flutter/material.dart';

/// Ganho por hora do dia — janelas de 3h, barra cinza e apagada quando não
/// houve corrida concluída na janela no período (não é barra zero, é
/// ausência de dado).
class HourlyEarningsChart extends StatelessWidget {
  final List<HourlyEarningEntry> entries;

  static const _chartHeight = 96.0;

  const HourlyEarningsChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final withData = entries.where((e) => e.amountPerHour != null).toList();

    if (withData.isEmpty) {
      return SizedBox(
        height: _chartHeight,
        child: Center(
          child: Text(
            'Sem corridas concluídas no período.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final peak = withData.reduce((a, b) => a.amountPerHour! > b.amountPerHour! ? a : b);
    final worst = withData.reduce((a, b) => a.amountPerHour! < b.amountPerHour! ? a : b);
    final max = peak.amountPerHour!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final entry in entries)
                Expanded(
                  child: _HourBar(
                    entry: entry,
                    ratio: entry.amountPerHour != null ? entry.amountPerHour! / max : null,
                    isPeak: identical(entry, peak),
                    color: colorScheme.primary,
                    emptyColor: colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Divider(color: colorScheme.outlineVariant, height: 1),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pico ${_rangeLabel(peak.startHour)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              'Pior ${_rangeLabel(worst.startHour)} · ${worst.amountPerHour!.formattedCurrency}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  String _rangeLabel(int startHour) {
    final end = (startHour + 3) % 24;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(startHour)}h–${two(end)}h';
  }
}

class _HourBar extends StatelessWidget {
  final HourlyEarningEntry entry;
  final double? ratio;
  final bool isPeak;
  final Color color;
  final Color emptyColor;

  const _HourBar({
    required this.entry,
    required this.ratio,
    required this.isPeak,
    required this.color,
    required this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = ratio != null;
    final barColor = !hasData
        ? emptyColor
        : isPeak
            ? color
            : color.withOpacity(0.45);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: hasData ? ratio!.clamp(0.02, 1).toDouble() : 0.02,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.startHour.toString().padLeft(2, '0'),
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
