import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/empty_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/section_header.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/shift_earnings_group.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

/// Lista de ganhos agrupada por jornada, com cabeçalho de mês.
///
/// Um lançamento sem jornada vinculada (promoção do dia, ajuste do
/// suporte) cai num grupo do próprio dia. Não existe tratamento especial
/// nem aviso pra isso: é só mais um dia com dinheiro entrando.
class EarningsListView extends StatelessWidget {
  final List<EarningEntity> earnings;
  final List<ShiftEntity> shifts;
  final void Function(EarningEntity earning)? onTapEarning;
  final VoidCallback? onCreate;

  const EarningsListView({
    super.key,
    required this.earnings,
    required this.shifts,
    this.onTapEarning,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();

    if (groups.isEmpty) {
      return EmptyStateView(
        icon: Icons.payments_outlined,
        title: 'Nenhum ganho lançado',
        message: 'Detalhe as corridas ao finalizar uma jornada, ou lance uma '
            'promoção ou ajuste aqui.',
        action: onCreate == null
            ? null
            : FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Novo lançamento'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                ),
              ),
      );
    }

    final items = _withMonthHeaders(groups);

    return ListView.builder(
      // bottom generoso pra o último card não ficar embaixo do FAB.
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
              trailingText: item.total.formattedCurrency,
            ),
          );
        }

        final group = item as _EarningsGroup;
        return ShiftEarningsGroup(
          shiftStartTime: group.date,
          shiftEarnings: group.shiftEarnings,
          earnings: group.earnings,
          onTapEarning: onTapEarning,
        );
      },
    );
  }

  List<_EarningsGroup> _buildGroups() {
    final byShift = <String, List<EarningEntity>>{};
    final looseByDay = <DateTime, List<EarningEntity>>{};

    for (final earning in earnings) {
      final shiftId = earning.shiftId;
      if (shiftId == null) {
        final day = DateTime(
          earning.occurredAt.year,
          earning.occurredAt.month,
          earning.occurredAt.day,
        );
        looseByDay.putIfAbsent(day, () => []).add(earning);
      } else {
        byShift.putIfAbsent(shiftId, () => []).add(earning);
      }
    }

    final groups = <_EarningsGroup>[];

    for (final shift in shifts) {
      final shiftEarnings = byShift[shift.id];
      if (shiftEarnings == null) continue;
      groups.add(
        _EarningsGroup(
          date: shift.startTime,
          shiftEarnings: shift.earnings,
          earnings: shiftEarnings..sort((a, b) => a.occurredAt.compareTo(b.occurredAt)),
        ),
      );
    }

    for (final entry in looseByDay.entries) {
      groups.add(
        _EarningsGroup(
          date: entry.key,
          shiftEarnings: null,
          earnings: entry.value..sort((a, b) => a.occurredAt.compareTo(b.occurredAt)),
        ),
      );
    }

    groups.sort((a, b) => b.date.compareTo(a.date));
    return groups;
  }

  List<Object> _withMonthHeaders(List<_EarningsGroup> groups) {
    final items = <Object>[];
    DateTime? currentMonth;

    for (var i = 0; i < groups.length; i++) {
      final month = DateTime(groups[i].date.year, groups[i].date.month);

      if (currentMonth == null || month != currentMonth) {
        currentMonth = month;
        final total = groups
            .where((g) => g.date.year == month.year && g.date.month == month.month)
            .fold<double>(0, (sum, g) => sum + g.total);
        items.add(_MonthHeader(month: month, total: total));
      }

      items.add(groups[i]);
    }

    return items;
  }
}

class _MonthHeader {
  final DateTime month;
  final double total;

  const _MonthHeader({required this.month, required this.total});
}

class _EarningsGroup {
  final DateTime date;
  final double? shiftEarnings;
  final List<EarningEntity> earnings;

  const _EarningsGroup({
    required this.date,
    required this.shiftEarnings,
    required this.earnings,
  });

  /// O total do mês soma o ganho declarado da jornada quando ele existe:
  /// é ele que representa o turno inteiro, não a soma dos lançamentos
  /// detalhados, que são opcionais.
  double get total =>
      shiftEarnings ?? earnings.fold<double>(0, (sum, e) => sum + e.amount);
}
