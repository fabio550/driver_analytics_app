import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceCostCreatePage extends ConsumerStatefulWidget {
  const MaintenanceCostCreatePage({super.key});

  @override
  ConsumerState<MaintenanceCostCreatePage> createState() =>
      _MaintenanceCostCreatePageState();
}

class _MaintenanceCostCreatePageState
    extends ConsumerState<MaintenanceCostCreatePage> {
  MaintenanceSubcategory _subcategory = MaintenanceSubcategory.oilChange;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  final _amountController = TextEditingController();
  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _odometerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time == null) return;

    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final odometerText = _odometerController.text.trim();
    final odometerKm =
        odometerText.isEmpty ? null : double.tryParse(odometerText.replaceAll(',', '.'));
    final description = _descriptionController.text.trim();

    await ref.read(costNotifierProvider.notifier).createMaintenanceCost(
          subcategory: _subcategory,
          amount: CurrencyInputFormatter.toDouble(_amountController.text),
          date: _date,
          odometerKm: odometerKm,
          description: description.isEmpty ? null : description,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ref.read(costNotifierProvider).validationFailures.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final failures = ref.watch(costNotifierProvider).validationFailures;
    List<ValidationFailure<CostField>> errorsFor(CostField field) {
      return failures.where((f) => f.field == field).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nova manutenção')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<MaintenanceSubcategory>(
              value: _subcategory,
              decoration: const InputDecoration(labelText: 'Serviço'),
              items: [
                for (final subcategory in MaintenanceSubcategory.values)
                  DropdownMenuItem(
                    value: subcategory,
                    child: Text(subcategory.label),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _subcategory = value);
              },
            ),
            const SizedBox(height: 16),
            DateTimeField<CostField>(
              label: 'Data',
              value: _date,
              errors: errorsFor(CostField.date),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            CurrencyField<CostField>(
              label: 'Valor pago',
              errors: errorsFor(CostField.amount),
              controller: _amountController,
            ),
            const SizedBox(height: 16),
            DistanceField<CostField>(
              label: 'Km do odômetro (opcional)',
              errors: errorsFor(CostField.odometerKm),
              onChanged: (_) {},
              controller: _odometerController,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: _subcategory == MaintenanceSubcategory.other
                    ? 'Descrição (obrigatória para "Outros")'
                    : 'Observação (opcional)',
                errorText: errorsFor(CostField.description).isNotEmpty
                    ? errorsFor(CostField.description).first.message
                    : null,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
