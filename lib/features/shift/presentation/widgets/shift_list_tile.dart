import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_stats.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_timeline.dart';
import 'package:flutter/material.dart';

/// Card de uma jornada na lista.
///
/// O cabeçalho abre com data e valor na mesma linha, que é o par que o
/// motorista procura. O chevron entrou pro cabeçalho: antes ele ficava
/// sozinho numa linha no rodapé do card, sem dizer o que ia abrir.
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
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final shift = widget.shift;
    final hasTimeline = shift.pauses.isNotEmpty || shift.endTime != null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              if (hasTimeline) ...[
                const SizedBox(height: AppSpacing.fieldPadding),
                ShiftTimeline(shift: shift),
                const SizedBox(height: AppSpacing.fieldPadding),
                Divider(color: colorScheme.outlineVariant, height: 1),
              ],
              const SizedBox(height: AppSpacing.fieldPadding),
              _buildMetrics(now),
              ShiftStats(shift: shift, now: now, isExpanded: _isExpanded),
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
      children: [
        Expanded(
          child: Text(
            widget.shift.startTime.formattedDayAndWeekday,
            style: textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)
                .tabular,
          ),
        ),
        Text(
          (widget.shift.earnings ?? 0).formattedCurrency,
          style: textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)
              .tabular,
        ),
        if (widget.onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Editar jornada',
            visualDensity: VisualDensity.compact,
            onPressed: widget.onEdit,
          ),
        Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildMetrics(DateTime now) {
    final shift = widget.shift;

    return Row(
      children: [
        Expanded(
          child: StatTile(
            label: 'trabalhado',
            value: shift.workedTime(now).formattedHHmm,
            valueFirst: true,
          ),
        ),
        Expanded(
          child: StatTile(
            label: 'rodados',
            value: shift.distanceKm.formattedKm,
            valueFirst: true,
          ),
        ),
        Expanded(
          child: StatTile(
            label: 'por hora',
            value: shift.earningsPerHour(now).formattedCurrencyOrDash,
            valueFirst: true,
          ),
        ),
      ],
    );
  }
}
