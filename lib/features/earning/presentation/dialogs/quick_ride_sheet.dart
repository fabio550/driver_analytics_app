import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/decimal_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/integer_field.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:driver_analytics_app/features/earning/presentation/state/ride_draft.dart';
import 'package:flutter/material.dart';

/// Lançamento rápido de uma corrida, com o mínimo pra ela existir:
/// tipo, hora, duração, distância e valor. Dinâmico, gorjeta, CEP e
/// observação ficam pra tela completa de corrida — aqui o motorista
/// está fechando o turno, não editando um lançamento.
class QuickRideSheet extends StatefulWidget {
  final DateTime initialTime;

  const QuickRideSheet({super.key, required this.initialTime});

  static Future<RideDraft?> show(
    BuildContext context, {
    required DateTime initialTime,
  }) {
    return showModalBottomSheet<RideDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => QuickRideSheet(initialTime: initialTime),
    );
  }

  @override
  State<QuickRideSheet> createState() => _QuickRideSheetState();
}

class _QuickRideSheetState extends State<QuickRideSheet> {
  late TimeOfDay _time;
  RideServiceType _serviceType = RideServiceType.uberX;

  final _fareController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay.fromDateTime(widget.initialTime);
    for (final controller in [_fareController, _durationController, _distanceController]) {
      controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in [_fareController, _durationController, _distanceController]) {
      controller.removeListener(_onChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  double get _fare => CurrencyInputFormatter.toDouble(_fareController.text);
  int get _durationMinutes => int.tryParse(_durationController.text) ?? 0;
  double get _distanceKm =>
      double.tryParse(_distanceController.text.replaceAll(',', '.')) ?? 0;

  bool get _isValid => _fare > 0 && _durationMinutes > 0 && _distanceKm > 0;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
  }

  void _submit() {
    if (!_isValid) return;

    final day = widget.initialTime;
    Navigator.of(context).pop(
      RideDraft(
        serviceType: _serviceType,
        occurredAt: DateTime(day.year, day.month, day.day, _time.hour, _time.minute),
        fare: _fare,
        durationSeconds: _durationMinutes * 60,
        distanceKm: _distanceKm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'NOVA CORRIDA',
                style: AppTextStyles.eyebrow.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final type in RideServiceType.values)
                    ChoiceChip(
                      label: Text(type.label),
                      selected: _serviceType == type,
                      onSelected: (_) => setState(() => _serviceType = type),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CurrencyField<EarningField>(
                label: 'Valor da corrida',
                errors: const [],
                controller: _fareController,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: IntegerField<EarningField>(
                      label: 'Duração (min)',
                      errors: const [],
                      controller: _durationController,
                      leading: const Icon(Icons.timer_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DecimalField<EarningField>(
                      label: 'Distância (km)',
                      errors: const [],
                      controller: _distanceController,
                      leading: const Icon(Icons.route_outlined, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text('Horário: ${_time.format(context)}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _isValid ? _submit : null,
                child: const Text('Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
