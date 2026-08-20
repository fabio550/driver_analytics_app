import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/use_cases/inputs/pause_input.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_field.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_form_state.dart';
import 'package:driver_analytics_app/features/shift/presentation/state/shift_pause_form_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftCreatePage extends ConsumerStatefulWidget {
  const ShiftCreatePage({super.key});

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
            _buildDateTimeTile(
              label: 'Início',
              value: _formState.startTime,
              errors: _formState.failuresFor(ShiftField.startTime),
              onTap: () => _pickStartTime(),
            ),
            const SizedBox(height: 12),
            _buildDateTimeTile(
              label: 'Fim (opcional)',
              value: _formState.endTime,
              errors: _formState.failuresFor(ShiftField.endTime),
              onTap: () => _pickEndTime(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialKmController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Km inicial',
                errorText: _errorTextFor(ShiftField.initialKm),
              ),
              onChanged: (value) => setState(
                () => _formState = _formState.copyWith(initialKm: value),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _finalKmController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Km final (opcional)',
                errorText: _errorTextFor(ShiftField.finalKm),
              ),
              onChanged: (value) => setState(
                () => _formState = _formState.copyWith(finalKm: value),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _earningsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Ganhos (opcional)',
                errorText: _errorTextFor(ShiftField.earnings),
              ),
              onChanged: (value) => setState(
                () => _formState = _formState.copyWith(earnings: value),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Pausas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addPause,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar pausa'),
                ),
              ],
            ),
            if (_formState.pauses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nenhuma pausa adicionada.'),
              ),
            for (var i = 0; i < _formState.pauses.length; i++)
              _buildPauseCard(index: i, entry: _formState.pauses[i]),
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

  Widget _buildPauseCard({
    required int index,
    required ShiftPauseFormEntry entry,
  }) {
    final errors = _formState.failuresForPause(index);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Pausa #${index + 1}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removePause(entry.id),
                ),
              ],
            ),
            _buildDateTimeTile(
              label: 'Início da pausa',
              value: entry.startTime,
              errors: const [],
              onTap: () => _pickPauseTime(entry.id, isStart: true),
            ),
            const SizedBox(height: 8),
            _buildDateTimeTile(
              label: 'Fim da pausa (opcional)',
              value: entry.endTime,
              errors: const [],
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

  String? _errorTextFor(ShiftField field) {
    final failures = _formState.failuresFor(field);
    return failures.isEmpty ? null : failures.first.message;
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
