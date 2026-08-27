import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/bordered_field_shell.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyField<TField> extends StatelessWidget {
  final String label;
  final List<ValidationFailure<TField>> errors;
  final TextEditingController controller;

  const CurrencyField({
    super.key,
    required this.label,
    required this.errors,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BorderedFieldShell(
      label: label,
      errorText: errors.isNotEmpty ? errors.first.message : null,
      leading: Text(
        'R\$',
        style: AppTextStyles.fieldPrefix.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.fieldPadding),
        ),
      ),
    );
  }
}
