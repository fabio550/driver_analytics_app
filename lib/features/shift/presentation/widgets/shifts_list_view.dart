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

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: shifts.length,
      separatorBuilder: (context, i) => const Divider(
        height: 1,
        thickness: 0.5,
        indent: 20,
        endIndent: 20,
        color: Color(0xff474747),
      ),
      itemBuilder: (context, i) => ShiftListTile(shift: shifts[i]),
    );
  }
}
