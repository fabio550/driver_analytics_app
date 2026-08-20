import 'package:flutter/material.dart';

/// Pergunta km final e ganho bruto. Devolve `(finalKm, earnings)` ou `null`
/// se cancelado.
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

  double? get _earnings =>
      double.tryParse(_earningsController.text.replaceAll(',', '.'));

  bool get _isValid =>
      _finalKm != null && _finalKm! > widget.initialKm && _earnings != null;

  @override
  void dispose() {
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
          TextField(
            controller: _earningsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Ganho bruto (R\$)'),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _confirm(),
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
