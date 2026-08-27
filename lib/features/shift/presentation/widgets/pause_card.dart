import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_form_state.dart';
import 'package:flutter/material.dart';

class PauseCard extends StatelessWidget {
  final int index;
  final ShiftFormState state;
  final ValueChanged<ShiftFormState> onChanged;

  const PauseCard({
    super.key,
    required this.index,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entry = state.pauses[index];
    final errors = state.failuresForPause(index);

    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Pausa ${index + 1}'),
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
              onTap: () => _pickPauseTime(context, entry.id, isStart: true),
            ),
            DateTimeField(
              label: 'Fim',
              value: entry.endTime,
              errors: [],
              onTap: () => _pickPauseTime(context, entry.id, isStart: false),
            ),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
                ...errors.map(
                (e) => Text(
                  e.message,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.error,
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
    onChanged(
      state.copyWith(
        pauses: state.pauses.where((p) => p.id != id).toList(),
      ),
    );
  }

  Future<void> _pickPauseTime(
    BuildContext context,
    int pauseId, {
    required bool isStart,
  }) async {
    final startTime = state.startTime;

    if (startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o horário de início da jornada primeiro.'),
        ),
      );
      return;
    }

    final pauseIndex = state.pauses.indexWhere((p) => p.id == pauseId);
    if (pauseIndex == -1) return;

    final entry = state.pauses[pauseIndex];

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
    if (time == null || !context.mounted) return;

    final picked = _resolveDateTime(anchor: anchor, time: time);

    final updatedEntry = isStart
        ? entry.copyWith(startTime: picked)
        : entry.copyWith(endTime: picked);

    final updatedPauses = [...state.pauses];
    updatedPauses[pauseIndex] = updatedEntry;

    onChanged(state.copyWith(pauses: updatedPauses));
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