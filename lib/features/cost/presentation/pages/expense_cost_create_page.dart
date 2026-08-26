import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/expense_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseCostCreatePage extends ConsumerStatefulWidget {
  const ExpenseCostCreatePage({super.key});

  @override
  ConsumerState<ExpenseCostCreatePage> createState() =>
      _ExpenseCostCreatePageState();
}

class _ExpenseCostCreatePageState extends ConsumerState<ExpenseCostCreatePage> {
  ExpenseSubcategory _subcategory = ExpenseSubcategory.toll;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

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

    await ref.read(costNotifierProvider.notifier).createExpenseCost(
          subcategory: _subcategory,
          amount: CurrencyInputFormatter.toDouble(_amountController.text),
          date: _date,
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
      appBar: AppBar(title: const Text('Nova despesa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ExpenseSubcategory>(
              value: _subcategory,
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
