import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/infrastructure/database/seed_data_provider.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_sizes.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/empty_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/error_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/section_header.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/analytics/application/providers/analytics_provider.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/start_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_summary_row.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/week_summary_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela do dia. Antes era um menu de quatro botões, que obrigava o
/// motorista a escolher um destino antes de ver qualquer coisa — e a
/// ação mais frequente do app (iniciar jornada) ficava a dois toques,
/// atrás de um ícone na barra de Jornadas.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();

    // Jornada em andamento sobrevive ao app fechar (fica persistida no
    // banco) — se o app reabre no meio de uma, é pra lá que o usuário
    // quer voltar, não pra home.
    Future.microtask(() async {
      await ref.read(activeShiftNotifierProvider.notifier).restore();
      if (!mounted) return;

      _loadIfNeeded();

      final activeShift = ref.read(activeShiftNotifierProvider).shift;
      if (activeShift != null && mounted) {
        context.push('/shifts/active');
      }
    });
  }

  void _loadIfNeeded() {
    if (ref.read(shiftNotifierProvider).status == LoadStatus.initial) {
      ref.read(shiftNotifierProvider.notifier).loadShifts();
    }
    if (ref.read(costNotifierProvider).status == LoadStatus.initial) {
      ref.read(costNotifierProvider.notifier).loadCosts();
    }
    if (ref.read(earningNotifierProvider).status == LoadStatus.initial) {
      ref.read(earningNotifierProvider.notifier).loadEarnings();
    }
  }

  Future<void> _reload() async {
    await Future.wait([
      ref.read(shiftNotifierProvider.notifier).loadShifts(),
      ref.read(costNotifierProvider.notifier).loadCosts(),
      ref.read(earningNotifierProvider.notifier).loadEarnings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ref.watch(shiftNotifierProvider.select((state) => state.status)),
      ref.watch(costNotifierProvider.select((state) => state.status)),
      ref.watch(earningNotifierProvider.select((state) => state.status)),
    ];
    final isLoading = statuses.any(
      (status) => status == LoadStatus.initial || status == LoadStatus.loading,
    );
    final hasError = statuses.any((status) => status == LoadStatus.error);

    return Scaffold(
      body: switch ((isLoading, hasError)) {
        (true, _) => const _HomeSkeleton(),
        (_, true) => ErrorStateView(
            message: 'Seus dados continuam salvos no aparelho. Tente abrir de novo.',
            onRetry: _reload,
          ),
        _ => _buildContent(context),
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final shifts = ref.watch(shiftNotifierProvider).shifts;
    final hasAnyShift = shifts.any((shift) => shift.status == ShiftStatus.submitted);

    if (!hasAnyShift) {
      return SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: EmptyStateView(
                icon: Icons.route_outlined,
                title: 'Nenhuma jornada ainda',
                message: 'Ao iniciar uma jornada o app passa a contar tempo, '
                    'pausas e km sozinho. É de onde vêm todas as análises.',
                action: FilledButton.icon(
                  onPressed: _startShift,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar jornada'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, AppSizes.buttonHeight),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  ),
                ),
                secondaryAction: TextButton(
                  onPressed: () => context.push('/shifts/create'),
                  child: const Text('Lançar uma jornada passada'),
                ),
              ),
            ),
            if (kDebugMode) _seedButton(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ScreenScrollView(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.lg),
          _startCta(),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            label: 'ESTA SEMANA',
            trailingText: 'Ver análises',
            onTrailingTap: () => context.go('/analytics'),
          ),
          const SizedBox(height: AppSpacing.sm),
          WeekSummaryCard(summary: ref.watch(currentWeekSummaryProvider)),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            label: 'ÚLTIMAS JORNADAS',
            trailingText: 'Ver todas',
            onTrailingTap: () => context.go('/shifts'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._recentShifts(shifts),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.lg),
            _seedButton(),
          ],
        ],
      ),
    );
  }

  List<Widget> _recentShifts(List<ShiftEntity> shifts) {
    final recent = shifts
        .where((shift) => shift.status == ShiftStatus.submitted)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final earnings = ref.watch(earningNotifierProvider).earnings;
    final rideCounts = <String, int>{};
    for (final earning in earnings) {
      final shiftId = earning.shiftId;
      if (shiftId == null || earning is! RideEarningEntity) continue;
      rideCounts[shiftId] = (rideCounts[shiftId] ?? 0) + 1;
    }

    return [
      for (final shift in recent.take(4))
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ShiftSummaryRow(
            shift: shift,
            rideCount: rideCounts[shift.id] ?? 0,
            onTap: () => context.go('/shifts'),
          ),
        ),
    ];
  }

  Widget _startCta() {
    final activeShift = ref.watch(activeShiftNotifierProvider).shift;
    final lastShift = ref.watch(lastSubmittedShiftProvider);

    if (activeShift != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () => context.push('/shifts/active'),
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Voltar pra jornada'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _caption('Começou às ${activeShift.startTime.formattedHHmm}'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _startShift,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Iniciar jornada'),
        ),
        if (lastShift != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _caption(
            'Última: ${lastShift.startTime.formattedDayAndWeekday.split(' · ').first} · '
            '${lastShift.workedTime(DateTime.now()).formattedHHmm} · '
            '${(lastShift.earnings ?? 0).formattedCurrency}',
          ),
        ],
      ],
    );
  }

  Widget _caption(String text) {
    return Builder(
      builder: (context) => Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)
            .tabular,
      ),
    );
  }

  Widget _seedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: OutlinedButton(
        onPressed: _isSeeding ? null : _seedSampleData,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        child: _isSeeding
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Popular dados de exemplo (debug)'),
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

  Future<void> _seedSampleData() async {
    setState(() => _isSeeding = true);

    await ref.read(seedDataServiceProvider).seed();
    await _reload();

    if (!mounted) return;
    setState(() => _isSeeding = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados de exemplo adicionados.')),
    );
  }
}

class _Header extends StatelessWidget {
  final EdgeInsets padding;

  const _Header({this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 0)});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Analytics',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            DateTime.now().formattedFullDate,
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)
                .tabular,
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const SkeletonBox(width: 210, height: 26),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonBox(width: 150, height: 14),
        const SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: AppSizes.buttonHeight, radius: AppRadius.lg),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(width: 120, height: 14),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonCard(
          children: [
            SkeletonBox(width: 96, height: 13),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(width: 200, height: 34),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 10),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 40),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(width: 140, height: 14),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < 3; i++) ...[
          SkeletonBox(height: 62, radius: AppRadius.md),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
