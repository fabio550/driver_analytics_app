import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final ShiftEntity shift;

  const SummaryCard({
    super.key,
    required this.shift,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final rows = <(String, String)>[
      ('Início', shift.startTime.formattedHHmm),
      ('Fim', shift.endTime != null
          ? shift.endTime!.formattedHHmmss
          : '--'),
      ('Tempo trabalhado', shift.workedTime(now).formattedHHmmss),
      ('Tempo pausado', shift.totalPausedTime(now).formattedHHmm),
      ('Km percorrido', shift.distanceKm.formattedKm),
      ('Ganho bruto', (shift.earnings ?? 0).formattedCurrency),
      if (shift.earningsPerKm() != null)
        ('R\$/km', shift.earningsPerKm()!.formattedCurrency),
      if (shift.earningsPerHour(now) != null)
        ('R\$/hora', shift.earningsPerHour(now)!.formattedCurrency),
      ('Pausas', '${shift.pauses.length}'),
    ];

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: rows.length,
        separatorBuilder: (context, i) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (label, value) = rows[i];

          return ListTile(
            title: Text(label),
            trailing: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
