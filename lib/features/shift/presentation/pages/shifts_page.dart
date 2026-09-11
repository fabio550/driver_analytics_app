import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/empty_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/error_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/start_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/active_shift_banner.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shifts_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      if (ref.read(shiftNotifierProvider).status == LoadStatus.initial) {
        ref.read(shiftNotifierProvider.notifier).loadShifts();
      }
      ref.read(activeShiftNotifierProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shiftNotifierProvider);
    final activeShift = ref.watch(activeShiftNotifierProvider).shift;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jornadas'),
        centerTitle: false,
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/shifts/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nova jornada'),
      ),
      body: Column(
        children: [
          if (activeShift != null) ActiveShiftBanner(shift: activeShift),
          Expanded(
            child: switch (state.status) {
              LoadStatus.initial || LoadStatus.loading => const _ShiftsSkeleton(),
              LoadStatus.error => ErrorStateView(
                  message: 'Suas jornadas continuam salvas no aparelho. '
                      'Tente abrir de novo.',
                  onRetry: () =>
                      ref.read(shiftNotifierProvider.notifier).loadShifts(),
                ),
              LoadStatus.loaded => state.shifts.isEmpty
                  ? EmptyStateView(
                      icon: Icons.route_outlined,
                      title: 'Nenhuma jornada ainda',
                      message: 'Ao iniciar uma jornada o app passa a contar '
                          'tempo, pausas e km sozinho. É de onde vêm todas as '
                          'análises.',
                      action: FilledButton.icon(
                        onPressed: activeShift != null ? null : _startShift,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar jornada'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                        ),
                      ),
                      secondaryAction: TextButton(
                        onPressed: () => context.push('/shifts/create'),
                        child: const Text('Lançar uma jornada passada'),
                      ),
                    )
                  : ShiftsListView(shifts: state.shifts),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startShift() async {
    final initialKm = await StartShiftDialog.show(context);
    if (initialKm == null || !mounted) return;

    await ref.read(activeShiftNotifierProvider.notifier).start(initialKm);
    if (!mounted) return;

    if (ref.read(activeShiftNotifierProvider).shift != null) {
      context.push('/shifts/active');
    }
  }
}

class _ShiftsSkeleton extends StatelessWidget {
  const _ShiftsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        96,
      ),
      children: [
        const SkeletonBox(width: 180, height: 14),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 4; i++) ...[
          const SkeletonCard(
            children: [
              SkeletonBox(height: 22),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 36),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
