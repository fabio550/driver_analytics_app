import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/section_header.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/delete_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Lista de jornadas agrupada por mês, com o total do mês no cabeçalho.
class ShiftsListView extends ConsumerStatefulWidget {
  final List<ShiftEntity> shifts;

  const ShiftsListView({super.key, required this.shifts});

  @override
  ConsumerState<ShiftsListView> createState() => _ShiftsListViewState();
}

class _ShiftsListViewState extends ConsumerState<ShiftsListView> {
  final _hiddenIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final visible = widget.shifts
        .where((shift) => !_hiddenIds.contains(shift.id))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final items = _withMonthHeaders(visible);

    return ListView.builder(
      // bottom generoso pra o último card não ficar embaixo do FAB
      // extended ("Nova jornada").
      padding: const EdgeInsets.only(top: 6, bottom: 96),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];

        if (item is _MonthHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: SectionHeader(
              label: item.month.formattedMonthAndYear,
              trailingText: '${item.count} '
                  '${item.count == 1 ? 'jornada' : 'jornadas'} · '
                  '${item.total.formattedCurrency}',
            ),
          );
        }

        final shift = item as ShiftEntity;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Dismissible(
            key: ValueKey(shift.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            confirmDismiss: (_) => DeleteShiftDialog.show(context),
            onDismissed: (_) {
              setState(() => _hiddenIds.add(shift.id));
              ref.read(shiftNotifierProvider.notifier).deleteShift(shift.id);
            },
            child: ShiftListTile(
              shift: shift,
              onEdit: () => context.push('/shifts/edit', extra: shift),
            ),
          ),
        );
      },
    );
  }

  List<Object> _withMonthHeaders(List<ShiftEntity> shifts) {
    final items = <Object>[];
    DateTime? currentMonth;

    for (final shift in shifts) {
      final month = DateTime(shift.startTime.year, shift.startTime.month);

      if (currentMonth == null || month != currentMonth) {
        currentMonth = month;
        final inMonth = shifts.where(
          (s) => s.startTime.year == month.year && s.startTime.month == month.month,
        );
        items.add(
          _MonthHeader(
            month: month,
            count: inMonth.length,
            total: inMonth.fold<double>(0, (sum, s) => sum + (s.earnings ?? 0)),
          ),
        );
      }

      items.add(shift);
    }

    return items;
  }
}

class _MonthHeader {
  final DateTime month;
  final int count;
  final double total;

  const _MonthHeader({
    required this.month,
    required this.count,
    required this.total,
  });
}
