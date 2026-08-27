import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_stats.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_timeline.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

class ShiftListTile extends StatefulWidget {
  final ShiftEntity shift;
  final VoidCallback? onEdit;

  const ShiftListTile({
    super.key,
    required this.shift,
    this.onEdit,
  });

  @override
  State<ShiftListTile> createState() => _ShiftListTileState();
}

class _ShiftListTileState extends State<ShiftListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              ShiftTimeline(shift: widget.shift),
              const SizedBox(height: AppSpacing.md),
              ShiftStats(
                shift: widget.shift,
                now: now,
                isExpanded: _isExpanded,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
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
          (widget.shift.earnings ?? 0).formattedCurrency,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        if (widget.onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: widget.onEdit,
          ),
      ],
    );
  }
}
