import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/widgets/empty_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/presentation/dialogs/delete_earning_dialog.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/earning_row_tile.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lista só os lançamentos (corridas, promoções, ajustes) de UMA
/// jornada — aberta pelo botão "Ver corridas" no card expandido da
/// tela de Jornadas. Mesma lógica de toque-pra-editar e swipe-pra-
/// excluir da aba Ganhos, só que já filtrada, sem precisar achar a
/// jornada certa numa lista com todos os meses misturados.
class ShiftRidesPage extends ConsumerStatefulWidget {
  final ShiftEntity shift;

  const ShiftRidesPage({super.key, required this.shift});

  @override
  ConsumerState<ShiftRidesPage> createState() => _ShiftRidesPageState();
}

class _ShiftRidesPageState extends ConsumerState<ShiftRidesPage> {
  final _hiddenIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (ref.read(earningNotifierProvider).status == LoadStatus.initial) {
        ref.read(earningNotifierProvider.notifier).loadEarnings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final earnings = state.earnings
        .where((e) => e.shiftId == widget.shift.id && !_hiddenIds.contains(e.id))
        .toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridas da jornada'),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Text(
              widget.shift.startTime.formattedDayAndWeekday,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: state.status == LoadStatus.loading || state.status == LoadStatus.initial
                ? const _RidesSkeleton()
                : earnings.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.list_alt_outlined,
                        title: 'Nenhuma corrida nesta jornada',
                        message: 'Lançamentos vinculados a essa jornada aparecem '
                            'aqui — importe um print ou lance manualmente em '
                            'Ganhos, associando a essa jornada.',
                      )
                    : _list(earnings),
          ),
        ],
      ),
    );
  }

  Widget _list(List<EarningEntity> earnings) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      itemCount: earnings.length,
      itemBuilder: (context, i) {
        final earning = earnings[i];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Dismissible(
              key: ValueKey(earning.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                color: colorScheme.errorContainer,
                child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
              ),
              confirmDismiss: (_) => DeleteEarningDialog.show(context),
              onDismissed: (_) async {
                setState(() => _hiddenIds.add(earning.id));
                await ref.read(earningNotifierProvider.notifier).deleteEarning(earning.id);
              },
              child: EarningRowTile(
                earning: earning,
                onTap: () => _navigateToEdit(earning),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToEdit(EarningEntity earning) {
    final route = switch (earning) {
      RideEarningEntity() => '/earnings/ride/edit',
      PromotionEarningEntity() => '/earnings/promotion/edit',
      AdjustmentEarningEntity() => '/earnings/adjustment/edit',
    };
    context.push(route, extra: earning);
  }
}

class _RidesSkeleton extends StatelessWidget {
  const _RidesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        for (var i = 0; i < 4; i++) ...[
          SkeletonBox(height: 64, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
