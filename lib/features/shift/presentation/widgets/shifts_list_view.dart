import 'package:driver_analytics_app/features/shift/presentation/widgets/shift_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';

class ShiftsListView extends StatelessWidget {
  final List<ShiftEntity> shifts;

  const ShiftsListView({
    super.key,
    required this.shifts,
  });

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return const Center(
        child: Text('Nenhum lançamento encontrado.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: shifts.length,
      itemBuilder: (context, i) => ShiftListTile(shift: shifts[i]),
    );
  }
}
