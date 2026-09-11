import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/discard_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftSummaryPage extends ConsumerWidget {
  const ShiftSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeShiftNotifierProvider);
    final shift = state.shift;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo da jornada')),
      bottomNavigationBar: shift == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed:
                          state.isSubmitting ? null : () => _confirm(context, ref),
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
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: const Text('Descartar'),
                    ),
                  ],
                ),
              ),
            ),
      body: shift == null
          ? const Center(child: Text('Nenhuma jornada para resumir.'))
          : ScreenScrollView(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [SummaryCard(shift: shift)],
            ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(activeShiftNotifierProvider.notifier).confirm();
    if (!context.mounted) return;
    if (success) {
      await ref.read(shiftNotifierProvider.notifier).loadShifts();
      // As corridas do turno acabaram de ser criadas: sem recarregar,
      // a lista de Lançamentos e as Análises seguiriam sem elas.
      await ref.read(earningNotifierProvider.notifier).loadEarnings();
      if (!context.mounted) return;
      context.go('/shifts');
    }
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final confirmed = await DiscardShiftDialog.show(context);
    if (confirmed != true || !context.mounted) return;
    final success = await ref.read(activeShiftNotifierProvider.notifier).discard();
    if (!context.mounted) return;
    if (success) {
      context.go('/shifts');
    }
  }
}
