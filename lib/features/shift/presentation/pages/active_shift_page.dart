import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/presentation/providers/clock_provider.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_sizes.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/timer_progress_border.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/finish_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/active_shift_stats.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_pause_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActiveShiftPage extends ConsumerWidget {
  const ActiveShiftPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeShiftState = ref.watch(activeShiftNotifierProvider);
    final shift = activeShiftState.shift;
    final now = ref.watch(clockProvider).value ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Jornada em andamento')),
      body: shift == null
          ? const Center(child: Text('Nenhuma jornada em andamento.'))
          : _ActiveShiftBody(now: now),
    );
  }
}

class _ActiveShiftBody extends ConsumerWidget {
  final DateTime now;

  const _ActiveShiftBody({required this.now});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeShiftNotifierProvider);
    final shift = state.shift!;
    final isPaused = shift.isPaused;
    final colorScheme = Theme.of(context).colorScheme;
    final workedTime = shift.workedTime(now);
    final accent = isPaused ? colorScheme.tertiary : colorScheme.primary;

    return ScreenScrollView(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          // A borda fecha exatamente quando o minuto vira no display, e
          // congela sozinha na pausa porque o progresso vem do tempo
          // trabalhado, não do relógio de parede.
          child: TimerProgressBorder(
            progress: (workedTime.inSeconds % 60) / 60,
            color: accent,
            trackColor: colorScheme.outlineVariant,
            child: Text(
              workedTime.formattedHHmm,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: accent,
                  ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'tempo trabalhado',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (isPaused) ...[
          const SizedBox(height: 12),
          Center(
            child: Chip(
              label: const Text('PAUSADO'),
              backgroundColor: colorScheme.tertiaryContainer,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        ActiveShiftStats(shift: shift, now: now),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: state.isSubmitting
              ? null
              : () {
                  final notifier = ref.read(activeShiftNotifierProvider.notifier);
                  isPaused ? notifier.resume() : notifier.pause();
                },
          style: FilledButton.styleFrom(
            backgroundColor: isPaused ? colorScheme.tertiary : null,
            minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          ),
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          label: Text(isPaused ? 'Retomar' : 'Pausar'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Pausas', style: Theme.of(context).textTheme.titleMedium),
        if (shift.pauses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text('Nenhuma pausa registrada.'),
          )
        else
          for (var i = 0; i < shift.pauses.length; i++)
            ShiftPauseTile(index: i, pause: shift.pauses[i], now: now),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: state.isSubmitting ? null : () => _finish(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          child: const Text('Finalizar jornada'),
        ),
      ],
    );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final shift = ref.read(activeShiftNotifierProvider).shift;
    if (shift == null) return;

    final result = await FinishShiftDialog.show(context, initialKm: shift.initialKm);

    if (result == null || !context.mounted) return;

    final (finalKm, earnings) = result;
    final notifier = ref.read(activeShiftNotifierProvider.notifier);
    await notifier.finish(finalKm: finalKm, earnings: earnings);
    if (!context.mounted) return;

    final updated = ref.read(activeShiftNotifierProvider).shift;
    if (updated?.status == ShiftStatus.finished) {
      context.push('/shifts/active/summary');
    }
  }
}