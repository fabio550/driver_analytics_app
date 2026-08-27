import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/form_scroll_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/shift_picker_field.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PromotionEarningCreatePage extends ConsumerStatefulWidget {
  final PromotionEarningEntity? existing;

  const PromotionEarningCreatePage({super.key, this.existing});

  @override
  ConsumerState<PromotionEarningCreatePage> createState() =>
      _PromotionEarningCreatePageState();
}

class _PromotionEarningCreatePageState
    extends ConsumerState<PromotionEarningCreatePage> {
  late DateTime _occurredAt;
  String? _shiftId;
  bool _isSubmitting = false;
  bool _shiftManuallyChanged = false;

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _occurredAt = existing?.occurredAt ?? DateTime.now();
    _shiftId = existing?.shiftId;
    _shiftManuallyChanged = existing != null;

    _amountController = TextEditingController(
      text: existing != null ? CurrencyInputFormatter.format(existing.amount) : '',
    );
    _descriptionController = TextEditingController(text: existing?.description ?? '');

    Future.microtask(() {
      ref.read(shiftNotifierProvider.notifier).loadShifts();
      ref.read(earningNotifierProvider.notifier).loadEarnings();
      if (!_shiftManuallyChanged) _autoSelectShift();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _autoSelectShift() {
    if (!mounted) return;
    final shifts = ref.read(shiftNotifierProvider).shifts;
    for (final shift in shifts) {
      final end = shift.endTime ?? DateTime.now();
      if (!_occurredAt.isBefore(shift.startTime) && !_occurredAt.isAfter(end)) {
        setState(() => _shiftId = shift.id);
        return;
      }
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null || !mounted) return;

    setState(() {
      _occurredAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });

    if (!_shiftManuallyChanged) _autoSelectShift();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final amount = CurrencyInputFormatter.toDouble(_amountController.text);
    final description = _descriptionController.text.trim();
    final notifier = ref.read(earningNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateEarning(
        PromotionEarningEntity(
          id: widget.existing!.id,
          shiftId: _shiftId,
          occurredAt: _occurredAt,
          description: description.isEmpty ? null : description,
          amount: amount,
        ),
      );
    } else {
      await notifier.createPromotionEarning(
        shiftId: _shiftId,
        occurredAt: _occurredAt,
        amount: amount,
        description: description.isEmpty ? null : description,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ref.read(earningNotifierProvider).validationFailures.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final failures = ref.watch(earningNotifierProvider).validationFailures;
    List<ValidationFailure<EarningField>> errorsFor(EarningField field) {
      return failures.where((f) => f.field == field).toList();
    }

    final shifts = ref.watch(shiftNotifierProvider).shifts;
    final earnings = ref.watch(earningNotifierProvider).earnings;
    final earningsByShift = <String, List<EarningEntity>>{};
    for (final earning in earnings) {
      final id = earning.shiftId;
      if (id == null) continue;
      earningsByShift.putIfAbsent(id, () => []).add(earning);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar promoção' : 'Nova promoção')),
      bottomNavigationBar: PrimaryButton(
        label: _isEditing ? 'Salvar alterações' : 'Salvar',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _submit,
      ),
      body: FormScrollView(
        children: [
          DateTimeField<EarningField>(
            label: 'Data e hora',
            value: _occurredAt,
            errors: errorsFor(EarningField.occurredAt),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: AppSpacing.md),
          ShiftPickerField(
            shifts: shifts,
            earningsByShift: earningsByShift,
            selectedShiftId: _shiftId,
            onChanged: (id) {
              setState(() {
                _shiftId = id;
                _shiftManuallyChanged = true;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyField<EarningField>(
            label: 'Valor',
            errors: errorsFor(EarningField.amount),
            controller: _amountController,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Descrição',
              errorText: errorsFor(EarningField.description).isNotEmpty
                  ? errorsFor(EarningField.description).first.message
                  : null,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}