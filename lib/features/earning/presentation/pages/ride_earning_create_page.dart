import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_time_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/decimal_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/integer_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/shift_picker_field.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideEarningCreatePage extends ConsumerStatefulWidget {
  final RideEarningEntity? existing;

  const RideEarningCreatePage({super.key, this.existing});

  @override
  ConsumerState<RideEarningCreatePage> createState() => _RideEarningCreatePageState();
}

class _RideEarningCreatePageState extends ConsumerState<RideEarningCreatePage> {
  static const _app = RideApp.uber;

  late DateTime _occurredAt;
  late RideServiceType _serviceType;
  late RideStatus _status;
  String? _shiftId;
  bool _isSubmitting = false;
  bool _shiftManuallyChanged = false;

  late final TextEditingController _fareController;
  late final TextEditingController _surgeController;
  late final TextEditingController _tipController;
  late final TextEditingController _durationController;
  late final TextEditingController _distanceController;
  late final TextEditingController _pickupCepController;
  late final TextEditingController _destinationCepController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _occurredAt = existing?.occurredAt ?? DateTime.now();
    _serviceType = existing?.serviceType ?? RideServiceType.uberX;
    _status = existing?.status ?? RideStatus.completed;
    _shiftId = existing?.shiftId;
    _shiftManuallyChanged = existing != null;

    _fareController = TextEditingController(
      text: existing != null ? CurrencyInputFormatter.format(existing.fare) : '',
    );
    _surgeController = TextEditingController(
      text: existing != null && existing.surge > 0
          ? CurrencyInputFormatter.format(existing.surge)
          : '',
    );
    _tipController = TextEditingController(
      text: existing != null && existing.tip > 0
          ? CurrencyInputFormatter.format(existing.tip)
          : '',
    );
    _durationController = TextEditingController(
      text: existing != null ? (existing.durationSeconds ~/ 60).toString() : '',
    );
    _distanceController = TextEditingController(
      text: existing != null
          ? existing.distanceKm.toStringAsFixed(1).replaceAll('.', ',')
          : '',
    );
    _pickupCepController = TextEditingController(text: existing?.pickupCep ?? '');
    _destinationCepController = TextEditingController(text: existing?.destinationCep ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');

    Future.microtask(() {
      ref.read(shiftNotifierProvider.notifier).loadShifts();
      ref.read(earningNotifierProvider.notifier).loadEarnings();
      if (!_shiftManuallyChanged) _autoSelectShift();
    });
  }

  @override
  void dispose() {
    _fareController.dispose();
    _surgeController.dispose();
    _tipController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _pickupCepController.dispose();
    _destinationCepController.dispose();
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

    final fare = CurrencyInputFormatter.toDouble(_fareController.text);
    final surge = CurrencyInputFormatter.toDouble(_surgeController.text);
    final tip = CurrencyInputFormatter.toDouble(_tipController.text);
    final durationMinutes = int.tryParse(_durationController.text) ?? 0;
    final distance = double.tryParse(_distanceController.text.replaceAll(',', '.')) ?? 0;
    final pickupCep = _pickupCepController.text.trim();
    final destinationCep = _destinationCepController.text.trim();
    final description = _descriptionController.text.trim();

    final notifier = ref.read(earningNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateEarning(
        RideEarningEntity(
          id: widget.existing!.id,
          shiftId: _shiftId,
          occurredAt: _occurredAt,
          description: description.isEmpty ? null : description,
          app: _app,
          serviceType: _serviceType,
          fare: fare,
          surge: surge,
          tip: tip,
          durationSeconds: durationMinutes * 60,
          distanceKm: distance,
          status: _status,
          pickupCep: pickupCep.isEmpty ? null : pickupCep,
          destinationCep: destinationCep.isEmpty ? null : destinationCep,
        ),
      );
    } else {
      await notifier.createRideEarning(
        shiftId: _shiftId,
        occurredAt: _occurredAt,
        description: description.isEmpty ? null : description,
        app: _app,
        serviceType: _serviceType,
        fare: fare,
        surge: surge,
        tip: tip,
        durationSeconds: durationMinutes * 60,
        distanceKm: distance,
        status: _status,
        pickupCep: pickupCep.isEmpty ? null : pickupCep,
        destinationCep: destinationCep.isEmpty ? null : destinationCep,
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar corrida' : 'Nova corrida')),
      bottomNavigationBar: PrimaryButton(
        label: _isEditing ? 'Salvar alterações' : 'Salvar',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _submit,
      ),
      body: ScreenScrollView(
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
          DropdownButtonFormField<RideServiceType>(
            initialValue: _serviceType,
            decoration: const InputDecoration(labelText: 'Tipo de serviço'),
            items: [
              for (final type in RideServiceType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _serviceType = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<RideStatus>(
            segments: [
              for (final status in RideStatus.values)
                ButtonSegment(value: status, label: Text(status.label)),
            ],
            selected: {_status},
            onSelectionChanged: (selection) {
              setState(() => _status = selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyField<EarningField>(
            label: 'Valor da corrida',
            errors: errorsFor(EarningField.fare),
            controller: _fareController,
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyField<EarningField>(
            label: 'Dinâmico (opcional)',
            errors: const [],
            controller: _surgeController,
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyField<EarningField>(
            label: 'Gorjeta (opcional)',
            errors: const [],
            controller: _tipController,
          ),
          const SizedBox(height: AppSpacing.md),
          IntegerField<EarningField>(
            label: 'Duração (min)',
            errors: errorsFor(EarningField.durationSeconds),
            controller: _durationController,
            leading: const Icon(Icons.timer),
          ),
          const SizedBox(height: AppSpacing.md),
          DecimalField<EarningField>(
            label: 'Distância (km)',
            errors: errorsFor(EarningField.distanceKm),
            controller: _distanceController,
            leading: const Icon(Icons.route),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _pickupCepController,
            decoration: InputDecoration(
              labelText: 'CEP de origem (opcional)',
              errorText: errorsFor(EarningField.pickupCep).isNotEmpty
                  ? errorsFor(EarningField.pickupCep).first.message
                  : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _destinationCepController,
            decoration: InputDecoration(
              labelText: 'CEP de destino (opcional)',
              errorText: errorsFor(EarningField.destinationCep).isNotEmpty
                  ? errorsFor(EarningField.destinationCep).first.message
                  : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Observação (opcional)'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}