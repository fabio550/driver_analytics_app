import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/presentation/dialogs/delete_shift_dialog.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftsListView extends ConsumerStatefulWidget {
  final List<ShiftEntity> shifts;

  const ShiftsListView({super.key, required this.shifts});

  @override
  ConsumerState<ShiftsListView> createState() => _ShiftsListViewState();
}

class _ShiftsListViewState extends ConsumerState<ShiftsListView> {
  // Ids removidos otimisticamente na tela, antes da exclusão no banco
  // confirmar — evita o Dismissible reaparecer no rebuild seguinte
  // enquanto o delete ainda está em andamento (ele lança erro se o item
  // continuar na árvore depois de dispensado).
  final _hiddenIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final visible = widget.shifts.where((s) => !_hiddenIds.contains(s.id)).toList();

    if (visible.isEmpty) {
      return const Center(
        child: Text('Nenhum lançamento encontrado.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: visible.length,
      itemBuilder: (context, i) {
        final shift = visible[i];

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
            setState(() => _hiddenIds.add(shift.id));
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