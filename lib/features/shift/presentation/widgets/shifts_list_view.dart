import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/delete_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftsListView extends ConsumerWidget {
  final List<ShiftEntity> shifts;

  const ShiftsListView({
    super.key,
    required this.shifts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (shifts.isEmpty) {
      return const Center(
        child: Text('Nenhum lançamento encontrado.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: shifts.length,
      itemBuilder: (context, i) {
        final shift = shifts[i];

        return Dismissible(
          key: ValueKey(shift.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          confirmDismiss: (_) => DeleteShiftDialog.show(context),
          onDismissed: (_) {
            ref.read(shiftNotifierProvider.notifier).deleteShift(shift.id);
          },
          child: ShiftListTile(
            shift: shift,
            onEdit: () => context.push('/shifts/edit', extra: shift),
          ),
        );
      },
    );
  }
}
