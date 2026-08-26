import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shifts_list_view.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/active_shift_banner.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/start_shift_dialog.dart';
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
      ref.read(activeShiftNotifierProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shiftNotifierProvider);
    final activeShift = ref.watch(activeShiftNotifierProvider).shift;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Iniciar jornada',
            onPressed:
                activeShift != null ? null : () => _startShift(context, ref),
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
          if (activeShift != null) ActiveShiftBanner(shift: activeShift),
          Expanded(
            child: switch (state.status) {
              LoadStatus.initial ||
              LoadStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              LoadStatus.loaded => ShiftsListView(shifts: state.shifts),
              LoadStatus.error => const ShiftsErrorView(),
            },
          ),
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
