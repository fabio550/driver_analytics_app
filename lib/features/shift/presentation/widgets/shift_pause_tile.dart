import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';
import 'package:flutter/material.dart';

class ShiftPauseTile extends StatelessWidget {
  final int index;
  final ShiftPauseEntity pause;
  final DateTime now;

  const ShiftPauseTile({
    super.key,
    required this.index,
    required this.pause,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = pause.isRunning;
    final duration = pause.duration(now);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.pause_circle_outline,
        color: isRunning ? Theme.of(context).colorScheme.tertiary : null,
      ),
      title: Text('Pausa #${index + 1}'),
      subtitle: Text(
        isRunning
            ? '${pause.startTime.formattedHHmm} → em andamento'
            : '${pause.startTime.formattedHHmm} → ${pause.endTime!.formattedHHmm}',
      ),
      trailing: Text(
        duration.formattedHHmmss,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isRunning ? Theme.of(context).colorScheme.tertiary : null,
        ),
      ),
    );
  }
}
