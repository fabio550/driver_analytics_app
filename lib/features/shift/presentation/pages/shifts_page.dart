import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/state/shift_load_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shifts_list_view.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/start_shift_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shifts_error_view.dart';

class ShiftsPage extends ConsumerStatefulWidget {
  const ShiftsPage({super.key});

  @override
  ConsumerState<ShiftsPage> createState() => _ShiftsPageState();
}

class _ShiftsPageState extends ConsumerState<ShiftsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(shiftNotifierProvider.notifier).loadShifts();
      // Recupera uma jornada em andamento caso o app tenha sido reaberto
      // no meio de uma (persistida a cada transição — ver ActiveShiftNotifier).
      ref.read(activeShiftNotifierProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shiftNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Iniciar jornada',
            // Evita criar uma segunda jornada por cima de uma já em
            // andamento (recuperada ou não).
            onPressed:
                activeShift != null ? null : () => _startShift(context, ref),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/shifts/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Jornada'),
      ),
      body: Column(
        children: [
          if (activeShift != null) _ActiveShiftBanner(shift: activeShift),
          Expanded(
            child: switch (state.status) {
              ShiftLoadStatus.initial ||
              ShiftLoadStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              ShiftLoadStatus.loaded => ShiftsListView(shifts: state.shifts),
              ShiftLoadStatus.error => const ShiftsErrorView(),
          },
        ],
      ),
    );
  }

  Future<void> _startShift(BuildContext context, WidgetRef ref) async {
    final initialKm = await StartShiftDialog.show(context);
    if (initialKm == null || !context.mounted) return;

    await ref.read(activeShiftNotifierProvider.notifier).start(initialKm);
    if (!context.mounted) return;

    final activeShift = ref.read(activeShiftNotifierProvider).shift;
    if (activeShift != null) {
      context.push('/shifts/active');
    }
  }
}

              final activeShift = ref.read(activeShiftNotifierProvider).shift;
    if (activeShift != null) {
      context.push('/shifts/active');
    }
  }
}

    final activeShift = ref.read(activeShiftNotifierProvider).shift;
    if (activeShift != null) {
      context.push('/shifts/active');
    }
  }
}

class _ActiveShiftBanner extends StatelessWidget {
  final ShiftEntity shift;

  const _ActiveShiftBanner({required this.shift});

  @override
  Widget build(BuildContext context) {
    final isPaused = shift.isPaused;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isPaused ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => context.push('/shifts/active'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(isPaused ? Icons.pause_circle : Icons.play_circle),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPaused
                      ? 'Jornada pausada — toque para voltar'
                      : 'Jornada em andamento — toque para voltar',
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
