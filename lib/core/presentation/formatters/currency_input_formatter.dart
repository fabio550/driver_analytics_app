import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Pega só os dígitos (remove tudo que não é número)
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Interpreta os dígitos como centavos
    double value = double.parse(digitsOnly) / 100;

    String newText = _formatter.format(value).trim();

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  /// Helper pra extrair o valor numérico (double) do texto formatado
  static double toDouble(String formattedText) {
    String digitsOnly = formattedText.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return 0.0;
    return double.parse(digitsOnly) / 100;
  }
}
