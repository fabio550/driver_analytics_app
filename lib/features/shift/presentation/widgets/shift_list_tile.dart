import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';
import 'package:flutter/material.dart';

class ShiftListTile extends StatefulWidget {
  final ShiftEntity shift;

  const ShiftListTile({
    super.key,
    required this.shift,
  });

  @override
  State<ShiftListTile> createState() => _ShiftListTileState();
}

class _ShiftListTileState extends State<ShiftListTile> {
  
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return InkWell(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Card(
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
              _buildStats(context, now, isExpanded),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                  )
                ],
              ),
            ],
          ),
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
            widget.shift.startTime.formattedFullDate,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _formatCurrency(widget.shift.earnings ?? 0),
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
          label: widget.shift.startTime.formattedHHmm,
        ),
        for (final pause in widget.shift.pauses) ...[
          _timelineArrow(colorScheme),
          _TimelinePauseChip(pause: pause, colorScheme: colorScheme),
        ],
        if (widget.shift.endTime != null) ...[
          _timelineArrow(colorScheme),
          _TimelinePoint(
            icon: Icons.stop_circle,
            color: colorScheme.primary,
            label: widget.shift.endTime!.formattedHHmm ,
          ),
        ],
      ],
    );
  }

  Widget _timelineArrow(ColorScheme colorScheme) {
    return Icon(Icons.arrow_right_alt, size: 16, color: colorScheme.outline);
  }

  Widget _buildStats(BuildContext context, DateTime now, bool isExpanded) {
    return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: isExpanded ? Column(
        children: [
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(label: 'Ganho total', value: _formatCurrency(widget.shift.earnings ?? 0)),
              _StatItem(label: 'Km total', value: _formatKm(widget.shift.distanceKm)),
            ],
          ),
          Row(
            children: [
              _StatItem(label: 'Tempo total', value: widget.shift.elapsedTime(now).formattedHHmmss),
              _StatItem(label: 'Tempo pausado', value: widget.shift.totalPausedTime(now).formattedHHmmss),
              _StatItem(label: 'Tempo ativo', value: widget.shift.workedTime(now).formattedHHmmss),
            ],
          ),
          Row(
            children: [
              _StatItem(label: 'Ganho/km', value: _formatCurrencyOrDash(widget.shift.earningsPerKm())),
              _StatItem(label: 'Ganho/hora', value: _formatCurrencyOrDash(widget.shift.earningsPerHour(now))),
            ],
          ),
        ]
      ) : SizedBox.shrink(),
    );
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
        ? '${pause.startTime.formattedHHmm}–${endTime.formattedHHmm}'
        : '${pause.startTime.formattedHHmm}–em aberto';

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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 10),
      child: Column(
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
      ),
    );
  }
}
