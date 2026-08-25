import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_form_state.dart';
import 'package:flutter/material.dart';

class PauseCard extends StatefulWidget {
  final int index;
  ShiftFormState state;

  PauseCard({
    super.key,
    required this.index,
    required this.state,
  });

  @override
  State<PauseCard> createState() => _PauseCardState();
}

class _PauseCardState extends State<PauseCard> {
  @override
  Widget build(BuildContext context) {

    final entry = widget.state.pauses[widget.index];
    final errors = widget.state.failuresForPause(widget.index);

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Pausa ${widget.index + 1}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removePause(entry.id),
                ),
              ],
            ),
            DateTimeField(
              label: 'Início',
              value: entry.startTime,
              errors: [],
              onTap: () => _pickPauseTime(entry.id, isStart: true),
            ),
            DateTimeField(
              label: 'Fim',
              value: entry.endTime,
              errors: [],
              onTap: () => _pickPauseTime(entry.id, isStart: false),
            ),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...errors.map(
                (e) => Text(
                  e.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _removePause(int id) {
    setState(() {
      widget.state = widget.state.copyWith(
        pauses: widget.state.pauses.where((p) => p.id != id).toList(),
      );
    });
  }

  Future<void> _pickPauseTime(int pauseId, {required bool isStart}) async {

    final startTime = widget.state.startTime;

    if (startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o horário de início da jornada primeiro.'),
        ),
      );
      return;
    }

    final pauseIndex = widget.state.pauses.indexWhere((p) => p.id == pauseId);
    if (pauseIndex == -1) return;

    final entry = widget.state.pauses[pauseIndex];

        // Início da pausa é ancorado no início da jornada; fim da pausa é
    // ancorado no próprio início dela.
    final anchor = isStart ? startTime : (entry.startTime ?? startTime);

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        (isStart ? entry.startTime : entry.endTime) ?? anchor,
      ),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time == null || !mounted) return;

    final picked = _resolveDateTime(anchor: anchor, time: time);
    
    final updatedEntry = isStart
        ? entry.copyWith(startTime: picked)
        : entry.copyWith(endTime: picked);

    final updatedPauses = [...widget.state.pauses];
    updatedPauses[pauseIndex] = updatedEntry;

    setState(() => widget.state = widget.state.copyWith(pauses: updatedPauses));
  }

  DateTime _resolveDateTime({
    required DateTime anchor,
    required TimeOfDay time,
  }) {
    var result = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
      time.hour,
      time.minute,
    );
    if (!result.isAfter(anchor)) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }


}

