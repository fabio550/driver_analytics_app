import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/inputs/pause_input.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_form_state.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_pause_form_entry.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/pause_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftCreatePage extends ConsumerStatefulWidget {
  const ShiftCreatePage({
    super.key
  });

  @override
  ConsumerState<ShiftCreatePage> createState() => _ShiftCreatePageState();
}

class _ShiftCreatePageState extends ConsumerState<ShiftCreatePage> {
  ShiftFormState _formState = const ShiftFormState();

  late final TextEditingController _initialKmController;
  late final TextEditingController _finalKmController;
  late final TextEditingController _earningsController;

  @override
  void initState() {
    super.initState();
    _initialKmController = TextEditingController();
    _finalKmController = TextEditingController();
    _earningsController = TextEditingController();
  }

  @override
  void dispose() {
    _initialKmController.dispose();
    _finalKmController.dispose();
    _earningsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Jornada')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateTimeField(
              label: 'Início',
              value: _formState.startTime,
              errors: _formState.failuresFor(ShiftField.startTime),
              onTap: () => _pickStartTime(),
            ),
            DateTimeField(
              label: 'Fim',
              value: _formState.endTime,
              errors: _formState.failuresFor(ShiftField.endTime),
              onTap: () => _pickEndTime(),
            ),
            DistanceField(
              label: 'Km inicial',
              errors: _formState.failuresFor(ShiftField.initialKm),
              onChanged: (value) => setState(
                () => _formState = _formState.copyWith(initialKm: value),
              ), 
              controller: _initialKmController
            ),
            DistanceField(
              label: 'Km final',
              errors: _formState.failuresFor(ShiftField.finalKm),
              onChanged: (value) => setState(
                () => _formState = _formState.copyWith(finalKm: value),
              ), 
              controller: _finalKmController
            ),
            CurrencyField(
              label: 'Ganhos',
              errors: _formState.failuresFor(ShiftField.earnings),
              controller: _earningsController,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: _addPause,
                  icon: const Icon(Icons.add),
                  label: const Text('Pausa'),
                ),
              ],
            ),
            if (_formState.pauses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nenhuma pausa adicionada.'),
              ),
            for (var i = 0; i < _formState.pauses.length; i++)
              PauseCard(
                index: i,
                state: _formState,
                onChanged: (updated) => setState(() => _formState = updated),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _formState.isSubmitting ? null : _submit,
              child: _formState.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeTile({
    required String label,
    required DateTime? value,
    required List<ValidationFailure<ShiftField>> errors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errors.isNotEmpty ? errors.first.message : null,
        ),
        child: Text(value != null ? _formatDateTime(value) : 'Selecionar'),
      ),
    );
  }

  /*Widget _buildPauseCard({
    required int index,
    required ShiftPauseFormEntry entry,
  }) {
    final errors = _formState.failuresForPause(index);
    return PauseCard(
      index: index,
      entry: entry,
      errors: errors,
      onPressed: () => _removePause(entry.id),
      onStartTimeTap: () => _pickPauseTime(entry.id, isStart: true),
      onEndTimeTap: () => _pickPauseTime(entry.id, isStart: false),
    );
  }*/
  
  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStartTime() async {
    final picked = await _pickDateTime(_formState.startTime);
    if (picked == null) return;
    setState(() => _formState = _formState.copyWith(startTime: picked));
  }

  /// Combina [time] com a data de [anchor], assumindo que é o mesmo dia —
  /// e avançando pro dia seguinte se o horário "voltar no tempo" em
  /// relação ao anchor (turno que passa da meia-noite, ex: começou 17:00
  /// e terminou 03:40 → assume que o fim foi no dia seguinte).
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

  Future<void> _pickEndTime() async {
    final startTime = _formState.startTime;
    if (startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o horário de início primeiro.'),
        ),
      );
      return;
    }

    // Jornada é sempre no mesmo dia (ou vira a noite pro seguinte) — só
    // pergunta a hora, o dia é deduzido a partir do início.
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_formState.endTime ?? startTime),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time == null || !mounted) return;

    final endTime = _resolveDateTime(anchor: startTime, time: time);
    setState(() => _formState = _formState.copyWith(endTime: endTime));
  }

  Future<void> _pickPauseTime(int pauseId, {required bool isStart}) async {

    final startTime = _formState.startTime;

    if (startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o horário de início da jornada primeiro.'),
        ),
      );
      return;
    }

    final pauseIndex = _formState.pauses.indexWhere((p) => p.id == pauseId);
    if (pauseIndex == -1) return;

    final entry = _formState.pauses[pauseIndex];

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

    final updatedPauses = [..._formState.pauses];
    updatedPauses[pauseIndex] = updatedEntry;

    setState(() => _formState = _formState.copyWith(pauses: updatedPauses));
  }

  void _addPause() {
    setState(() {
      _formState = _formState.copyWith(
        pauses: [
          ..._formState.pauses,
          ShiftPauseFormEntry(id: _formState.nextPauseId),
        ],
        nextPauseId: _formState.nextPauseId + 1,
      );
    });
  }

  void _removePause(int id) {
    setState(() {
      _formState = _formState.copyWith(
        pauses: _formState.pauses.where((p) => p.id != id).toList(),
      );
    });
  }

  Future<void> _submit() async {
    final initialKm = double.tryParse(_formState.initialKm.replaceAll(',', '.'));
    final startTime = _formState.startTime;
    final endTime = _formState.endTime;
    final finalKm = _formState.finalKm.trim().isEmpty
        ? null
        : double.tryParse(_formState.finalKm.replaceAll(',', '.'));
    final earningsFilled = _earningsController.text.trim().isNotEmpty;

    // Lançamento manual já entra como jornada definitiva (submitted) — não
    // faz sentido salvar um registro histórico incompleto, então todos os
    // campos são obrigatórios aqui (diferente do fluxo "ao vivo", que
    // preenche km final/ganhos só no fim).
    if (initialKm == null || startTime == null ||
        endTime == null || finalKm == null || !earningsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preencha todos os campos.'),        ),
      );
        return;
    }
    
    final earnings = CurrencyInputFormatter.toDouble(_earningsController.text);

    final pauses = _formState.pauses
        .where((p) => p.startTime != null)
        .map((p) => PauseInput(startTime: p.startTime!, endTime: p.endTime))
        .toList();

    setState(() => _formState = _formState.copyWith(isSubmitting: true));

    await ref.read(shiftNotifierProvider.notifier).createShift(
          initialKm: initialKm,
          startTime: startTime,
          status: ShiftStatus.submitted,
          finalKm: finalKm,
          earnings: earnings,
          endTime: endTime,
          pauses: pauses,
        );

    if (!mounted) return;

    final validationFailures = ref.read(shiftNotifierProvider).validationFailures;
    if (validationFailures.isEmpty) {
      context.pop();
      return;
    }

    setState(() {
      _formState = _formState.copyWith(
        failures: validationFailures,
        isSubmitting: false,
      );
    });
  }

  String _formatDateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}


