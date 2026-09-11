import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de valor em destaque, pro número principal de um formulário.
///
/// Num formulário de custo o valor pago é o dado que o motorista veio
/// lançar; o resto é contexto. Antes ele tinha a mesma caixa de 48px de
/// todos os outros campos e se perdia no meio deles.
class AmountField<TField> extends StatelessWidget {
  final List<ValidationFailure<TField>> errors;
  final TextEditingController controller;
  final bool autofocus;

  const AmountField({
    super.key,
    required this.errors,
    required this.controller,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      style: textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)
          .tabular,
      decoration: InputDecoration(
        hintText: '0,00',
        prefixText: 'R\$ ',
        prefixStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorText: errors.isNotEmpty ? errors.first.message : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: border(colorScheme.outlineVariant, 1),
        focusedBorder: border(colorScheme.primary, 2),
        errorBorder: border(colorScheme.error, 1),
        focusedErrorBorder: border(colorScheme.error, 2),
      ),
    );
  }
}
