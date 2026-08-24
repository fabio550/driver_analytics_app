import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';
import 'package:flutter/material.dart';

class ShiftListTile extends StatelessWidget {
  final ShiftEntity shift;

  const ShiftListTile({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 14),
            _buildTimeline(context),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            _buildStats(context, now),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _formatFullDate(shift.startTime),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _formatCurrency(shift.earnings ?? 0),
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _TimelinePoint(
          icon: Icons.play_circle_fill,
          color: colorScheme.primary,
          label: _formatTime(shift.startTime),
        ),
        for (final pause in shift.pauses) ...[
          _timelineArrow(colorScheme),
          _TimelinePauseChip(pause: pause, colorScheme: colorScheme),
        ],
        if (shift.endTime != null) ...[
          _timelineArrow(colorScheme),
          _TimelinePoint(
            icon: Icons.flag_circle,
            color: colorScheme.tertiary,
            label: _formatTime(shift.endTime!),
          ),
        ],
      ],
    );
  }

  Widget _timelineArrow(ColorScheme colorScheme) {
    return Icon(Icons.arrow_right_alt, size: 16, color: colorScheme.outline);
  }

  Widget _buildStats(BuildContext context, DateTime now) {
    final stats = <(String, String)>[
      ('Ganho total', _formatCurrency(shift.earnings ?? 0)),
      ('Km total', _formatKm(shift.distanceKm)),
      ('Tempo total', _formatDuration(shift.elapsedTime(now))),
      ('Tempo pausado', _formatDuration(shift.totalPausedTime(now))),
      ('Tempo ativo', _formatDuration(shift.workedTime(now))),
      ('Ganho/km', _formatCurrencyOrDash(shift.earningsPerKm())),
      ('Ganho/hora', _formatCurrencyOrDash(shift.earningsPerHour(now))),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: [
        for (final (label, value) in stats)
          _StatItem(label: label, value: value),
      ],
    );
  }

  String _formatFullDate(DateTime date) {
    const weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
    final weekday = weekdays[date.weekday - 1];
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} · $weekday';
  }

  String _formatTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }

  String _formatDuration(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes % 60)}';
  }

  String _formatKm(double km) => '${km.toStringAsFixed(0)} km';

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatCurrencyOrDash(double? value) {
    if (value == null) return '—';
    return _formatCurrency(value);
  }
}

class _TimelinePoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _TimelinePoint({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimelinePauseChip extends StatelessWidget {
  final ShiftPauseEntity pause;
  final ColorScheme colorScheme;

  const _TimelinePauseChip({
    required this.pause,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final endTime = pause.endTime;
    final label = endTime != null
        ? '${_time(pause.startTime)}–${_time(endTime)}'
        : '${_time(pause.startTime)}–em aberto';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause, size: 12, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _time(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
