import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftSummaryPage extends ConsumerWidget {
  const ShiftSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeShiftNotifierProvider);
    final shift = state.shift;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo da jornada')),
      body: shift == null
          ? const Center(child: Text('Nenhuma jornada para resumir.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _SummaryCard(shift: shift)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        state.isSubmitting ? null : () => _confirm(context, ref),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirmar'),
                  ),
                  TextButton(
                    onPressed:
                        state.isSubmitting ? null : () => _discard(context, ref),
                    child: const Text('Descartar'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(activeShiftNotifierProvider.notifier).confirm();
    if (!context.mounted) return;
    if (success) {
      await ref.read(shiftNotifierProvider.notifier).loadShifts();
      if (!context.mounted) return;
      context.go('/shifts');
    }
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar jornada?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(activeShiftNotifierProvider.notifier).discard();
    if (!context.mounted) return;
    if (success) {
      context.go('/shifts');
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final ShiftEntity shift;

  const _SummaryCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final rows = <(String, String)>[
      ('Início', shift.startTime.formattedHHmm),
      ('Fim', shift.endTime != null ? shift.endTime!.formattedHHmmss : '--'),
      ('Tempo trabalhado', shift.workedTime(now).formattedHHmmss),
      ('Tempo pausado', shift.totalPausedTime(now).formattedHHmm),
      ('Km percorrido', shift.distanceKm.formattedKm),
      ('Ganho bruto', (shift.earnings ?? 0).formattedCurrency),
      if (shift.earningsPerKm() != null)
        ('R\$/km', shift.earningsPerKm()!.formattedCurrency),
      if (shift.earningsPerHour(now) != null)
        ('R\$/hora', shift.earningsPerHour(now)!.formattedCurrency),
      ('Pausas', '${shift.pauses.length}'),
    ];

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: rows.length,
        separatorBuilder: (context, i) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (label, value) = rows[i];
          return ListTile(
            title: Text(label),
            trailing: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}
