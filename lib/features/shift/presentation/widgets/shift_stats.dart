import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

/// A parte que só aparece com o card aberto. Fica de fora do fechado
/// tudo que já está na grade de métricas do cabeçalho — aqui entra a
/// decomposição do tempo e o ganho por km.
class ShiftStats extends StatelessWidget {
  final ShiftEntity shift;
  final DateTime now;
  final bool isExpanded;

  const ShiftStats({
    super.key,
    required this.shift,
    required this.now,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isExpanded ? _expanded(context) : const SizedBox(width: double.infinity),
    );
  }

  Widget _expanded(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.fieldPadding),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: AppSpacing.fieldPadding),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Tempo total',
                value: shift.elapsedTime(now).formattedHHmm,
              ),
            ),
            Expanded(
              child: StatTile(
                label: 'Tempo pausado',
                value: shift.totalPausedTime(now).formattedHHmm,
              ),
            ),
            Expanded(
              child: StatTile(
                label: 'Ganho/km',
                value: shift.earningsPerKm().formattedCurrencyOrDash,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Km inicial',
                value: shift.initialKm.formattedKm,
              ),
            ),
            Expanded(
              child: StatTile(
                label: 'Km final',
                value: (shift.finalKm ?? shift.initialKm).formattedKm,
              ),
            ),
            Expanded(
              child: StatTile(
                label: 'Pausas',
                value: '${shift.pauses.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
