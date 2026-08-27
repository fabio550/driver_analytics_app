import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/maintenance_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceCostCreatePage extends ConsumerStatefulWidget {
  final MaintenanceCostEntity? existing;

  const MaintenanceCostCreatePage({super.key, this.existing});

  @override
  ConsumerState<MaintenanceCostCreatePage> createState() =>
      _MaintenanceCostCreatePageState();
}

class _MaintenanceCostCreatePageState
    extends ConsumerState<MaintenanceCostCreatePage> {
  late MaintenanceSubcategory _subcategory;
  late DateTime _date;
  bool _isSubmitting = false;

  late final TextEditingController _amountController;
  late final TextEditingController _odometerController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _subcategory = existing?.subcategory ?? MaintenanceSubcategory.oilChange;
    _date = existing?.date ?? DateTime.now();

    _amountController = TextEditingController(
      text: existing != null ? CurrencyInputFormatter.format(existing.amount) : '',
    );
    _odometerController = TextEditingController(
      text: existing?.odometerKm?.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(text: existing?.description ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _odometerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await DateField.pick(context, initialDate: _date);
    if (date == null || !mounted) return;
    setState(() => _date = date);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final odometerText = _odometerController.text.trim();
    final odometerKm =
        odometerText.isEmpty ? null : double.tryParse(odometerText.replaceAll(',', '.'));
    final description = _descriptionController.text.trim();
    final amount = CurrencyInputFormatter.toDouble(_amountController.text);
    final notifier = ref.read(costNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateCost(
        MaintenanceCostEntity(
          id: widget.existing!.id,
          amount: amount,
          date: _date,
          description: description.isEmpty ? null : description,
          subcategory: _subcategory,
          odometerKm: odometerKm,
        ),
      );
    } else {
      await notifier.createMaintenanceCost(
        subcategory: _subcategory,
        amount: amount,
        date: _date,
        odometerKm: odometerKm,
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar manutenção' : 'Nova manutenção'),),
      bottomNavigationBar: PrimaryButton(
        label: _isEditing ? 'Salvar alterações' : 'Salvar',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _submit,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    : Text(_isEditing ? 'Salvar alterações' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
