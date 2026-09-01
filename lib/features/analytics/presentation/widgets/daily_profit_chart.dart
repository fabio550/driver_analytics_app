import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';
import 'package:flutter/material.dart';

/// Barra por dia: sobe do zero quando o lucro do dia é positivo, desce
/// quando é negativo — sem lib de gráfico, só Column dividida ao meio
/// pela linha de base.
class DailyProfitChart extends StatelessWidget {
  final List<DailyProfitEntry> entries;

  static const _chartHeight = 120.0;
  static const _barWidth = 20.0;

  const DailyProfitChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox(
        height: _chartHeight,
        child: Center(child: Text('Sem lançamentos no período.')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final maxAbs = entries
        .map((e) => e.netProfit.abs())
        .fold<double>(0, (max, value) => value > max ? value : max);

    return SizedBox(
      height: _chartHeight + 24,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in entries)
              _DayBar(
                entry: entry,
                maxAbs: maxAbs,
                positiveColor: colorScheme.primary,
                negativeColor: colorScheme.error,
                dividerColor: colorScheme.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final DailyProfitEntry entry;
  final double maxAbs;
  final Color positiveColor;
  final Color negativeColor;
  final Color dividerColor;

  const _DayBar({
    required this.entry,
    required this.maxAbs,
    required this.positiveColor,
    required this.negativeColor,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    const halfHeight = DailyProfitChart._chartHeight / 2;
    final ratio = maxAbs > 0 ? entry.netProfit.abs() / maxAbs : 0.0;
    final barHeight = ratio * halfHeight;
    final isPositive = entry.netProfit >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: DailyProfitChart._barWidth + 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: halfHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _bar(isPositive ? barHeight : 0, positiveColor),
              ),
            ),
            Divider(color: dividerColor, height: 1),
            SizedBox(
              height: halfHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: _bar(isPositive ? 0 : barHeight, negativeColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.date.day.toString().padLeft(2, '0')}/'
              '${entry.date.month.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double height, Color color) {
    return Container(
      width: DailyProfitChart._barWidth,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
