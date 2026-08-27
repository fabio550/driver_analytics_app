import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_kind.dart';
import 'package:driver_analytics_app/features/earning/presentation/dialogs/earning_kind_sheet.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/orphan_earnings_banner.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/shift_earnings_group.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EarningsPage extends ConsumerStatefulWidget {
  const EarningsPage({super.key});

  @override
  ConsumerState<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends ConsumerState<EarningsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(earningNotifierProvider.notifier).loadEarnings();
      ref.read(shiftNotifierProvider.notifier).loadShifts();
    });
  }

  Future<void> _openCreateSheet() async {
    final kind = await EarningKindSheet.show(context);
    if (kind == null || !mounted) return;

    final route = switch (kind) {
      EarningKind.ride => '/earnings/ride/create',
      EarningKind.promotion => '/earnings/promotion/create',
      EarningKind.adjustment => '/earnings/adjustment/create',
    };
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final earningState = ref.watch(earningNotifierProvider);
    final shiftState = ref.watch(shiftNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ganhos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        child: const Icon(Icons.add),
      ),
      body: switch (earningState.status) {
        LoadStatus.initial ||
        LoadStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        LoadStatus.error => const Center(
            child: Text('Não foi possível carregar os ganhos.'),
          ),
        LoadStatus.loaded => _buildContent(earningState.earnings, shiftState.shifts),
      },
    );
  }

  Widget _buildContent(List<EarningEntity> earnings, List<ShiftEntity> shifts) {
    final orphans = earnings.where((e) => e.shiftId == null).toList();

    final byShift = <String, List<EarningEntity>>{};
    for (final earning in earnings) {
      final shiftId = earning.shiftId;
      if (shiftId == null) continue;
      byShift.putIfAbsent(shiftId, () => []).add(earning);
    }

    final shiftsWithEarnings = shifts.where((s) => byShift.containsKey(s.id)).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (orphans.isEmpty && shiftsWithEarnings.isEmpty) {
      return const Center(child: Text('Nenhum ganho lançado.'));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 6, bottom: 96),
      children: [
        if (orphans.isNotEmpty)
          OrphanEarningsBanner(
            count: orphans.length,
            onTap: () => context.push('/earnings/orphans'),
          ),
        for (final shift in shiftsWithEarnings)
          ShiftEarningsGroup(
            shiftStartTime: shift.startTime,
            informedAmount: shift.earnings,
            earnings: byShift[shift.id]!,
            onTapEarning: (earning) {
              if (earning is RideEarningEntity) {
                context.push('/earnings/ride/edit', extra: earning);
              }
            },
          ),
      ],
    );
  }
}
