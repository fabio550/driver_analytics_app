import 'package:flutter/material.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';

class ShiftListTile extends StatelessWidget {
  final ShiftEntity shift;

  const ShiftListTile({required this.shift});

  @override
  Widget build(BuildContext context) {
    final earnings = shift.earnings ?? 0;
    final distanceKm = (shift.finalKm ?? shift.initialKm) - shift.initialKm;
    final duration = shift.endTime?.difference(shift.startTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(shift.startTime),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatTime(shift.startTime)} - '
                  '${shift.endTime != null ? _formatTime(shift.endTime!) : '--:--'}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${distanceKm.toStringAsFixed(0)} km'
                  '${duration != null ? ' • ${_formatDuration(duration)}' : ''}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'R\$ ${earnings.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes % 60)}';
  }
}
