import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

/// O que a jornada rendeu, logo depois de finalizar. O ganho bruto é o
/// número grande; o resto é a conta que o sustenta.
class SummaryCard extends StatelessWidget {
  final ShiftEntity shift;

  const SummaryCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final endTime = shift.endTime;
    final window = endTime == null
        ? shift.startTime.formattedHHmm
        : '${shift.startTime.formattedHHmm} → ${endTime.formattedHHmm}';

    final stats = <(String, String)>[
      ('Trabalhado', shift.workedTime(now).formattedHHmm),
      ('Pausado', shift.totalPausedTime(now).formattedHHmm),
      ('Km percorrido', shift.distanceKm.formattedKm),
      ('R\$/km', shift.earningsPerKm().formattedCurrencyOrDash),
      ('R\$/hora', shift.earningsPerHour(now).formattedCurrencyOrDash),
      ('Pausas', '${shift.pauses.length}'),
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganho bruto',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              (shift.earnings ?? 0).formattedCurrency,
              style: textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)
                  .tabular,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${shift.startTime.formattedDayAndWeekday} · $window',
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)
                  .tabular,
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.1,
              mainAxisSpacing: AppSpacing.md,
              children: [
                for (final (label, value) in stats)
                  StatTile(label: label, value: value, valueFirst: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
