import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
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

  static const _itemPadding = EdgeInsets.fromLTRB(0, 0, 12, 10);

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
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatTile(
                      label: 'Ganho total',
                      value: (shift.earnings ?? 0).formattedCurrency,
                      padding: _itemPadding,
                    ),
                    StatTile(
                      label: 'Km total',
                      value: shift.distanceKm.formattedKm,
                      padding: _itemPadding,
                    ),
                  ],
                ),
                Row(
                  children: [
                    StatTile(
                      label: 'Tempo total',
                      value: shift.elapsedTime(now).formattedHHmmss,
                      padding: _itemPadding,
                    ),
                    StatTile(
                      label: 'Tempo pausado',
                      value: shift.totalPausedTime(now).formattedHHmmss,
                      padding: _itemPadding,
                    ),
                    StatTile(
                      label: 'Tempo ativo',
                      value: shift.workedTime(now).formattedHHmmss,
                      padding: _itemPadding,
                    ),
                  ],
                ),
                Row(
                  children: [
                    StatTile(
                      label: 'Ganho/km',
                      value: shift.earningsPerKm().formattedCurrencyOrDash,
                      padding: _itemPadding,
                    ),
                    StatTile(
                      label: 'Ganho/hora',
                      value: shift.earningsPerHour(now).formattedCurrencyOrDash,
                      padding: _itemPadding,
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}