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
            ? '${_formatTime(pause.startTime)} → em andamento'
            : '${_formatTime(pause.startTime)} → ${_formatTime(pause.endTime!)}',
      ),
      trailing: Text(
        _formatDuration(duration),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isRunning ? Theme.of(context).colorScheme.tertiary : null,
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }

  String _formatDuration(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = two(duration.inHours);
    final minutes = two(duration.inMinutes % 60);
    final seconds = two(duration.inSeconds % 60);
    return '$hours:$minutes:$seconds';
  }
}
