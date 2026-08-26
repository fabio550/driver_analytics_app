import 'package:flutter/material.dart';

/// Pergunta o Km inicial e devolve o valor digitado (ou `null` se cancelado).
class StartShiftDialog extends StatefulWidget {
  const StartShiftDialog({super.key});

  @override
  State<StartShiftDialog> createState() => _StartShiftDialogState();

  static Future<double?> show(BuildContext context) {
    return showDialog<double>(
      context: context,
      builder: (context) => const StartShiftDialog(),
    );
  }
}

class _StartShiftDialogState extends State<StartShiftDialog> {
  final _controller = TextEditingController();

  double? get _parsedValue =>
      double.tryParse(_controller.text.replaceAll(',', '.'));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Iniciar jornada'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Km inicial'),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (_parsedValue != null) {
            Navigator.of(context).pop(_parsedValue);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _parsedValue == null
              ? null
              : () => Navigator.of(context).pop(_parsedValue),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
