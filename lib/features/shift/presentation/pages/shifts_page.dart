import 'package:driver_analytics_app/features/shift/application/state/shift_load_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shifts_list_view.dart';
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

    Future.microtask(
      () => ref.read(shiftNotifierProvider.notifier).loadShifts(),
    );
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
            onPressed: () => _startShift(context, ref),
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
      body: switch (state.status) {
        ShiftLoadStatus.initial || ShiftLoadStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
        ShiftLoadStatus.loaded => ShiftsListView(shifts: state.shifts),
        ShiftLoadStatus.error => const ShiftsErrorView(),
      },
    );
  }
}
