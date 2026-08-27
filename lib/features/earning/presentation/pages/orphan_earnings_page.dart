import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/earning_row_tile.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrphanEarningsPage extends ConsumerStatefulWidget {
  const OrphanEarningsPage({super.key});

  @override
  ConsumerState<OrphanEarningsPage> createState() => _OrphanEarningsPageState();
}

class _OrphanEarningsPageState extends ConsumerState<OrphanEarningsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(earningNotifierProvider.notifier).loadEarnings();
      ref.read(shiftNotifierProvider.notifier).loadShifts();
    });
  }

  Future<void> _assignToShift(EarningEntity earning) async {
    final shifts = ref.read(shiftNotifierProvider).shifts;
    final sorted = [...shifts]..sort((a, b) => b.startTime.compareTo(a.startTime));

    final shiftId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'ATRIBUIR A UM TURNO',
                    style: AppTextStyles.eyebrow.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (sorted.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text('Nenhum turno cadastrado ainda.'),
                  ),
                for (final shift in sorted)
                  ListTile(
                    title: Text(
                      '${shift.startTime.formattedDDMMYYYY} · ${shift.startTime.formattedHHmm}',
                    ),
                    subtitle: shift.earnings != null
                        ? Text('${shift.earnings!.formattedCurrency} informado')
                        : null,
                    onTap: () => Navigator.of(context).pop(shift.id),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (shiftId == null || !mounted) return;

    final updated = _withShiftId(earning, shiftId);
    await ref.read(earningNotifierProvider.notifier).updateEarning(updated);
  }

  EarningEntity _withShiftId(EarningEntity earning, String shiftId) {
    return switch (earning) {
      RideEarningEntity() => RideEarningEntity(
          id: earning.id,
          shiftId: shiftId,
          occurredAt: earning.occurredAt,
          description: earning.description,
          app: earning.app,
          serviceType: earning.serviceType,
          fare: earning.fare,
          surge: earning.surge,
          tip: earning.tip,
          durationSeconds: earning.durationSeconds,
          distanceKm: earning.distanceKm,
          status: earning.status,
          pickupCep: earning.pickupCep,
          destinationCep: earning.destinationCep,
          pickupDistrictId: earning.pickupDistrictId,
          destinationDistrictId: earning.destinationDistrictId,
        ),
      PromotionEarningEntity() => PromotionEarningEntity(
          id: earning.id,
          shiftId: shiftId,
          occurredAt: earning.occurredAt,
          description: earning.description,
          amount: earning.amount,
        ),
      AdjustmentEarningEntity() => AdjustmentEarningEntity(
          id: earning.id,
          shiftId: shiftId,
          occurredAt: earning.occurredAt,
          description: earning.description,
          amount: earning.amount,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final earningState = ref.watch(earningNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sem jornada')),
      body: switch (earningState.status) {
        LoadStatus.initial ||
        LoadStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        LoadStatus.error => const Center(
            child: Text('Não foi possível carregar os ganhos.'),
          ),
        LoadStatus.loaded => _buildContent(earningState.earnings),
      },
    );
  }

  Widget _buildContent(List<EarningEntity> earnings) {
    final orphans = earnings.where((e) => e.shiftId == null).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    if (orphans.isEmpty) {
      return const Center(child: Text('Nenhum lançamento sem jornada.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: orphans.length,
      separatorBuilder: (context, i) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final earning = orphans[i];
        return EarningRowTile(
          earning: earning,
          onTap: () => _assignToShift(earning),
        );
      },
    );
  }
}
