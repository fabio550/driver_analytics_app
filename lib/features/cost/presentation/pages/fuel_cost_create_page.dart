import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FuelCostCreatePage extends ConsumerStatefulWidget {
  final FuelCostEntity? existing;

  const FuelCostCreatePage({super.key, this.existing});

  @override
  ConsumerState<FuelCostCreatePage> createState() => _FuelCostCreatePageState();
}

class _FuelCostCreatePageState extends ConsumerState<FuelCostCreatePage> {
  late FuelSubcategory _subcategory;
  late DateTime _date;
  late bool _isFullTank;
  late bool _previousFillUpMissing;
  bool _isSubmitting = false;

  late final TextEditingController _amountController;
  late final TextEditingController _odometerController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _subcategory = existing?.subcategory ?? FuelSubcategory.ethanolCommon;
    _date = existing?.date ?? DateTime.now();
    _isFullTank = existing?.isFullTank ?? false;
    _previousFillUpMissing = existing?.previousFillUpMissing ?? false;

    _amountController = TextEditingController(
      text: existing != null ? CurrencyInputFormatter.format(existing.amount) : '',
    );
    _odometerController = TextEditingController(
      text: existing?.odometerKm.toStringAsFixed(0) ?? '',
    );
    _quantityController = TextEditingController(
      text: existing != null
          ? existing.quantity.toStringAsFixed(1).replaceAll('.', ',')
          : '',
    );
    _descriptionController = TextEditingController(text: existing?.description ?? '');
  }

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
    final date = await DateField.pick(context, initialDate: _date);
    if (date == null || !mounted) return;
    setState(() => _date = date);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final odometerKm = double.tryParse(_odometerController.text.replaceAll(',', '.')) ?? 0;
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;
    final description = _descriptionController.text.trim();
    final amount = CurrencyInputFormatter.toDouble(_amountController.text);
    final notifier = ref.read(costNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateCost(
        FuelCostEntity(
          id: widget.existing!.id,
          amount: amount,
          date: _date,
          description: description.isEmpty ? null : description,
          subcategory: _subcategory,
          odometerKm: odometerKm,
          quantity: quantity,
          isFullTank: _isFullTank,
          previousFillUpMissing: _previousFillUpMissing,
        ),
      );
    } else {
      await notifier.createFuelCost(
        subcategory: _subcategory,
        amount: amount,
        date: _date,
        odometerKm: odometerKm,
        quantity: quantity,
        isFullTank: _isFullTank,
        previousFillUpMissing: _previousFillUpMissing,
        description: description.isEmpty ? null : description,
      );
    }

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
      appBar: AppBar(title: Text(_isEditing ? 'Editar abastecimento' : 'Novo abastecimento'),),
      bottomNavigationBar: PrimaryButton(
        label: _isEditing ? 'Salvar alterações' : 'Salvar',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _submit,
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<FuelSubcategory>(
                  initialValue: _subcategory,
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
                DateField(
                  label: 'Data',
                  value: _date,
                  errors: errorsFor(CostField.date),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                CurrencyField(
                  label: 'Valor pago',
                  errors: errorsFor(CostField.amount),
                  controller: _amountController,
                ),
                const SizedBox(height: 16),
                DistanceField(
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
              ],
            ),
          ),
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
