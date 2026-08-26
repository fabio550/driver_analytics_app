import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';
import 'package:flutter/material.dart';

class ShiftTimeline extends StatelessWidget {
  final ShiftEntity shift;

  const ShiftTimeline({
    super.key,
    required this.shift,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _TimelinePoint(
          icon: Icons.play_circle_fill,
          color: colorScheme.primary,
          label: shift.startTime.formattedHHmm,
        ),
        for (final pause in shift.pauses) ...[
          _timelineArrow(colorScheme),
          _TimelinePauseChip(
            pause: pause,
            colorScheme: colorScheme,
          ),
        ],
        if (shift.endTime != null) ...[
          _timelineArrow(colorScheme),
          _TimelinePoint(
            icon: Icons.stop_circle,
            color: colorScheme.primary,
            label: shift.endTime!.formattedHHmm,
          ),
        ],
      ],
    );
  }

  Widget _timelineArrow(ColorScheme colorScheme) {
    return Icon(
      Icons.arrow_right_alt,
      size: 16,
      color: colorScheme.outline,
    );
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
        Icon(
          icon,
          size: 18,
          color: color,
        ),
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
        ? '${pause.startTime.formattedHHmm}–${endTime.formattedHHmm}'
        : '${pause.startTime.formattedHHmm}–em aberto';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pause,
            size: 12,
            color: colorScheme.onTertiaryContainer,
          ),
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
}
