import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FuelCostCreatePage extends ConsumerStatefulWidget {
  const FuelCostCreatePage({super.key});

  @override
  ConsumerState<FuelCostCreatePage> createState() => _FuelCostCreatePageState();
}

class _FuelCostCreatePageState extends ConsumerState<FuelCostCreatePage> {
  FuelSubcategory _subcategory = FuelSubcategory.ethanolCommon;
  DateTime _date = DateTime.now();
  bool _isFullTank = false;
  bool _previousFillUpMissing = false;
  bool _isSubmitting = false;

  final _amountController = TextEditingController();
  final _odometerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _odometerController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _quantityUnit => _subcategory == FuelSubcategory.energy ? 'kWh' : 'L';

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

    final odometerKm = double.tryParse(_odometerController.text.replaceAll(',', '.')) ?? 0;
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;
    final description = _descriptionController.text.trim();

    await ref.read(costNotifierProvider.notifier).createFuelCost(
          subcategory: _subcategory,
          amount: CurrencyInputFormatter.toDouble(_amountController.text),
          date: _date,
          odometerKm: odometerKm,
          quantity: quantity,
          isFullTank: _isFullTank,
          previousFillUpMissing: _previousFillUpMissing,
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
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<FuelSubcategory>(
              value: _subcategory,
              decoration: const InputDecoration(labelText: 'Combustível'),
              items: [
                for (final subcategory in FuelSubcategory.values)
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
              label: 'Km do odômetro',
              errors: errorsFor(CostField.odometerKm),
              onChanged: (_) {},
              controller: _odometerController,
            ),
            const SizedBox(height: 16),
            _buildQuantityField(errorsFor(CostField.quantity)),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _isFullTank,
              onChanged: (value) => setState(() => _isFullTank = value ?? false),
              title: const Text('Tanque cheio'),
              subtitle: const Text('Referência confiável pro cálculo de consumo.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: _previousFillUpMissing,
              onChanged: (value) =>
                  setState(() => _previousFillUpMissing = value ?? false),
              title: const Text('Abastecimento anterior em falta'),
              subtitle: const Text('Quebra a cadeia de cálculo de consumo aqui.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Observação (opcional)'),
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

  Widget _buildQuantityField(List<ValidationFailure<CostField>> errors) {
    return InputDecorator(
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: 'Quantidade ($_quantityUnit)',
        errorText: errors.isNotEmpty ? errors.first.message : null,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0DED8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
