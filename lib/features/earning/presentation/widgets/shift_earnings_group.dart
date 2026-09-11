import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/earning_row_tile.dart';
import 'package:flutter/material.dart';

/// Cartão de uma jornada com seus lançamentos. A lista de Ganhos é
/// agrupada por jornada, não por tipo, porque é assim que o motorista
/// pensa no dinheiro que entrou: um turno de cada vez.
class ShiftEarningsGroup extends StatelessWidget {
  final DateTime shiftStartTime;
  final double? shiftEarnings;
  final List<EarningEntity> earnings;
  final void Function(EarningEntity earning)? onTapEarning;

  const ShiftEarningsGroup({
    super.key,
    required this.shiftStartTime,
    required this.shiftEarnings,
    required this.earnings,
    this.onTapEarning,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = shiftEarnings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shiftStartTime.formattedDayAndWeekday,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)
                          .tabular,
                    ),
                  ),
                  if (total != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          total.formattedCurrency,
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)
                              .tabular,
                        ),
                        Text(
                          'ganho da jornada',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Divider(color: colorScheme.outlineVariant, height: 1),
            for (final earning in earnings)
              EarningRowTile(
                earning: earning,
                onTap: onTapEarning == null ? null : () => onTapEarning!(earning),
              ),
            Container(
              color: colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.fromLTRB(14, 9, 14, 11),
              child: Text(
                '${earnings.length} '
                '${earnings.length == 1 ? 'lançamento detalhado' : 'lançamentos detalhados'}',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)
                    .tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
