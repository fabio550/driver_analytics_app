import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

/// Contexto da jornada em andamento: o que o motorista informou ao
/// iniciar, mais a decomposição do tempo que sustenta o relógio do topo.
/// Ganho, km final e R$/h ficam de fora de propósito — só existem depois
/// de finalizar, e mostrar "—" pra todos eles seria só ruído.
class ActiveShiftStats extends StatelessWidget {
  final ShiftEntity shift;
  final DateTime now;

  const ActiveShiftStats({
    super.key,
    required this.shift,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Início',
                    value: shift.startTime.formattedHHmm,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'Km inicial',
                    value: shift.initialKm.formattedKm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Tempo total',
                    value: shift.elapsedTime(now).formattedHHmmss,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'Tempo pausado',
                    value: shift.totalPausedTime(now).formattedHHmmss,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}