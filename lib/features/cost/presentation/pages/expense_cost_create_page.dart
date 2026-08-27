import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseCostCreatePage extends ConsumerStatefulWidget {
  final ExpenseCostEntity? existing;

  const ExpenseCostCreatePage({super.key, this.existing});

  @override
  ConsumerState<ExpenseCostCreatePage> createState() =>
      _ExpenseCostCreatePageState();
}

class _ExpenseCostCreatePageState extends ConsumerState<ExpenseCostCreatePage> {
  late ExpenseSubcategory _subcategory;
  late DateTime _date;
  bool _isSubmitting = false;

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _subcategory = existing?.subcategory ?? ExpenseSubcategory.toll;
    _date = existing?.date ?? DateTime.now();

    _amountController = TextEditingController(
      text: existing != null ? CurrencyInputFormatter.format(existing.amount) : '',
    );
    _descriptionController = TextEditingController(text: existing?.description ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
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

    final description = _descriptionController.text.trim();
    final amount = CurrencyInputFormatter.toDouble(_amountController.text);
    final notifier = ref.read(costNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateCost(
        ExpenseCostEntity(
          id: widget.existing!.id,
          amount: amount,
          date: _date,
          description: description.isEmpty ? null : description,
          subcategory: _subcategory,
        ),
      );
    } else {
      await notifier.createExpenseCost(
        subcategory: _subcategory,
        amount: amount,
        date: _date,
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar despesa' : 'Nova despesa')),
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
              DropdownButtonFormField<ExpenseSubcategory>(
                initialValue: _subcategory,
                decoration: const InputDecoration(labelText: 'Tipo de despesa'),
                items: [
                  for (final subcategory in ExpenseSubcategory.values)
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
              DateTimeField(
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
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: _subcategory == ExpenseSubcategory.other
                      ? 'Descrição (obrigatória para "Outros")'
                      : 'Observação (opcional)',
                  errorText: errorsFor(CostField.description).isNotEmpty
                      ? errorsFor(CostField.description).first.message
                      : null,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
