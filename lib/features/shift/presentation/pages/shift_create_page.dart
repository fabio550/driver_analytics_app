import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/infrastructure/services/uuid_generator_provider.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/form_scroll_view.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/inputs/pause_input.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_pause_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_form_state.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_pause_form_entry.dart';
import 'package:driver_analytics_app/features/shift/presentation/widgets/pause_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftCreatePage extends ConsumerStatefulWidget {
  final ShiftEntity? existing;

  const ShiftCreatePage({super.key, this.existing});

  @override
  ConsumerState<ShiftCreatePage> createState() => _ShiftCreatePageState();
}

class _ShiftCreatePageState extends ConsumerState<ShiftCreatePage> {
  ShiftFormState _formState = const ShiftFormState();

  late final TextEditingController _initialKmController;
  late final TextEditingController _finalKmController;
  late final TextEditingController _earningsController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _initialKmController = TextEditingController();
    _finalKmController = TextEditingController();
    _earningsController = TextEditingController();

    final existing = widget.existing;
    if (existing != null) {
      final pauses = [
        for (var i = 0; i < existing.pauses.length; i++)
          ShiftPauseFormEntry(
            id: i,
            startTime: existing.pauses[i].startTime,
            endTime: existing.pauses[i].endTime,
          ),
      ];

      _formState = ShiftFormState(
        initialKm: existing.initialKm.toStringAsFixed(0),
        finalKm: existing.finalKm?.toStringAsFixed(0) ?? '',
        startTime: existing.startTime,
        endTime: existing.endTime,
        pauses: pauses,
        nextPauseId: pauses.length,
      );

      _initialKmController.text = _formState.initialKm;
      _finalKmController.text = _formState.finalKm;
      if (existing.earnings != null) {
        _earningsController.text = CurrencyInputFormatter.format(existing.earnings!);
      }
    }
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar Jornada' : 'Nova Jornada')),
      bottomNavigationBar: PrimaryButton(
        label: _isEditing ? 'Salvar alterações' : 'Salvar',
        isLoading: _formState.isSubmitting,
        onPressed: _formState.isSubmitting ? null : _submit,
      ),
      body: FormScrollView(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DateTimeField(
            label: 'Início',
            value: _formState.startTime,
            errors: _formState.failuresFor(ShiftField.startTime),
            onTap: () => _pickStartTime(),
          ),
          const SizedBox(height: AppSpacing.md),
          DateTimeField(
            label: 'Fim',
            value: _formState.endTime,
            errors: _formState.failuresFor(ShiftField.endTime),
            onTap: () => _pickEndTime(),
          ),
          const SizedBox(height: AppSpacing.md),
          DistanceField(
            label: 'Km inicial',
            errors: _formState.failuresFor(ShiftField.initialKm),
            onChanged: (value) => setState(
              () => _formState = _formState.copyWith(initialKm: value),
            ),
            controller: _initialKmController,
          ),
          const SizedBox(height: AppSpacing.md),
          DistanceField(
            label: 'Km final',
            errors: _formState.failuresFor(ShiftField.finalKm),
            onChanged: (value) => setState(
              () => _formState = _formState.copyWith(finalKm: value),
            ),
            controller: _finalKmController,
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyField(
            label: 'Ganhos',
            errors: _formState.failuresFor(ShiftField.earnings),
            controller: _earningsController,
          ),
          const SizedBox(height: AppSpacing.lg),
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
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text('Nenhuma pausa adicionada.'),
            ),
          for (var i = 0; i < _formState.pauses.length; i++)
            PauseCard(
              index: i,
              state: _formState,
              onChanged: (updated) => setState(() => _formState = updated),
            ),
        ],
      ),
    );
  }

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

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_formState.endTime ?? startTime),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time == null || !mounted) return;

    final endTime = _resolveDateTime(anchor: startTime, time: time);
    setState(() => _formState = _formState.copyWith(endTime: endTime));
  }

  void _addPause() {
    final pauses = _formState.pauses;
    if (pauses.isNotEmpty) {
      final last = pauses.last;
      if (last.startTime == null || last.endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Preencha o início e o fim da pausa anterior antes de adicionar outra.',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _formState = _formState.copyWith(
        pauses: [
          ...pauses,
          ShiftPauseFormEntry(id: _formState.nextPauseId),
        ],
        nextPauseId: _formState.nextPauseId + 1,
      );
    });
  }

  Future<void> _submit() async {
    final initialKm = double.tryParse(_formState.initialKm.replaceAll(',', '.'));
    final startTime = _formState.startTime;

    if (initialKm == null || startTime == null) {
      setState(() {
        _formState = _formState.copyWith(
          failures: [
            if (initialKm == null)
              const ValidationFailure(
                field: ShiftField.initialKm,
                message: 'Km inicial é obrigatório.',
              ),
            if (startTime == null)
              const ValidationFailure(
                field: ShiftField.startTime,
                message: 'Horário de início é obrigatório.',
              ),
          ],
        );
      });
      return;
    }

    final endTime = _formState.endTime;
    final finalKm = _formState.finalKm.trim().isEmpty
        ? null
        : double.tryParse(_formState.finalKm.replaceAll(',', '.'));
    final earnings = _earningsController.text.trim().isEmpty
        ? null
        : CurrencyInputFormatter.toDouble(_earningsController.text);

    final pauseInputs = _formState.pauses
        .where((p) => p.startTime != null)
        .map((p) => PauseInput(startTime: p.startTime!, endTime: p.endTime))
        .toList();

    setState(() => _formState = _formState.copyWith(isSubmitting: true));

    if (_isEditing) {
      final idGenerator = ref.read(uuidGeneratorProvider);
      final entity = ShiftEntity(
        id: widget.existing!.id,
        status: widget.existing!.status,
        initialKm: initialKm,
        finalKm: finalKm,
        earnings: earnings,
        startTime: startTime,
        endTime: endTime,
        pauses: pauseInputs
            .map((p) => ShiftPauseEntity(
                  id: idGenerator.generate(),
                  startTime: p.startTime,
                  endTime: p.endTime,
                ))
            .toList(),
      );
      await ref.read(shiftNotifierProvider.notifier).updateShift(entity);
    } else {
      await ref.read(shiftNotifierProvider.notifier).createShift(
            initialKm: initialKm,
            startTime: startTime,
            status: ShiftStatus.submitted,
            finalKm: finalKm,
            earnings: earnings,
            endTime: endTime,
            pauses: pauseInputs,
          );
    }

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
}