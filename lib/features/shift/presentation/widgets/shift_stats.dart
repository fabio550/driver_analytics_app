import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

class ShiftStats extends StatelessWidget {
  final ShiftEntity shift;
  final DateTime now;
  final bool isExpanded;

  const ShiftStats({
    super.key,
    required this.shift,
    required this.now,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isExpanded
          ? Column(
              children: [
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(
                      label: 'Ganho total',
                      value: (shift.earnings ?? 0).formattedCurrency,
                    ),
                    _StatItem(
                      label: 'Km total',
                      value: shift.distanceKm.formattedKm,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _StatItem(
                      label: 'Tempo total',
                      value: shift.elapsedTime(now).formattedHHmmss,
                    ),
                    _StatItem(
                      label: 'Tempo pausado',
                      value: shift.totalPausedTime(now).formattedHHmmss,
                    ),
                    _StatItem(
                      label: 'Tempo ativo',
                      value: shift.workedTime(now).formattedHHmmss,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _StatItem(
                      label: 'Ganho/km',
                      value: shift
                          .earningsPerKm()
                          .formattedCurrencyOrDash,
                    ),
                    _StatItem(
                      label: 'Ganho/hora',
                      value: shift
                          .earningsPerHour(now)
                          .formattedCurrencyOrDash,
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        12,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
