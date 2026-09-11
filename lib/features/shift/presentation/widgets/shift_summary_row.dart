import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

/// Linha compacta de uma jornada, pro bloco "últimas jornadas" do Início.
/// É mais rasa que o card de [ShiftListTile] de propósito: aqui a lista é
/// um atalho, não o lugar de investigar a jornada.
class ShiftSummaryRow extends StatelessWidget {
  final ShiftEntity shift;
  final int rideCount;
  final VoidCallback? onTap;

  const ShiftSummaryRow({
    super.key,
    required this.shift,
    required this.rideCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    final details = [
      shift.workedTime(now).formattedHHmm,
      shift.distanceKm.formattedKm,
      if (rideCount > 0) '$rideCount ${rideCount == 1 ? 'corrida' : 'corridas'}',
    ].join(' · ');

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: AppSpacing.fieldPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.startTime.formattedDayAndWeekday,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)
                          .tabular,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details,
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)
                          .tabular,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (shift.earnings ?? 0).formattedCurrency,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)
                        .tabular,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shift.earningsPerHour(now).formattedCurrencyOrDash}/h',
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)
                        .tabular,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
