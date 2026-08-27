import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:flutter/material.dart';

class FinishShiftDialog extends StatefulWidget {
  final double initialKm;

  const FinishShiftDialog({super.key, required this.initialKm});

  @override
  State<FinishShiftDialog> createState() => _FinishShiftDialogState();

  static Future<(double, double?)?> show(
    BuildContext context, {
    required double initialKm,
  }) {
    return showDialog<(double, double?)>(
      context: context,
      builder: (context) => FinishShiftDialog(initialKm: initialKm),
    );
  }
}

class _FinishShiftDialogState extends State<FinishShiftDialog> {
  final _finalKmController = TextEditingController();
  final _earningsController = TextEditingController();

  double? get _finalKm =>
      double.tryParse(_finalKmController.text.replaceAll(',', '.'));

  double get _earnings => CurrencyInputFormatter.toDouble(_earningsController.text);

  bool get _isValid =>
      _finalKm != null &&
      _finalKm! > widget.initialKm &&
      _earningsController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // CurrencyField não expõe onChanged — escuta o controller direto pra
    // reavaliar _isValid a cada dígito digitado.
    _earningsController.addListener(_onEarningsChanged);
  }

  void _onEarningsChanged() => setState(() {});

  @override
  void dispose() {
    _earningsController.removeListener(_onEarningsChanged);
    _finalKmController.dispose();
    _earningsController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_isValid) return;
    Navigator.of(context).pop((_finalKm!, _earnings));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finalizar jornada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Km inicial: ${widget.initialKm.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _finalKmController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Km final',
              errorText: _finalKm != null && _finalKm! <= widget.initialKm
                  ? 'Deve ser maior que o km inicial'
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('Ganho bruto', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          CurrencyField(
            label: 'Ganhos',
            errors: [],
            controller: _earningsController,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isValid ? _confirm : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}