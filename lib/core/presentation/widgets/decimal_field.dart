import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/bordered_field_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo numérico decimal com vírgula (litros, km, kWh) — mesma casca
/// visual dos outros campos, sem máscara de moeda. O rótulo pode
/// embutir a unidade dinamicamente (ex.: "Quantidade (L)").
class DecimalField<TField> extends StatelessWidget {
  final String label;
  final List<ValidationFailure<TField>> errors;
  final TextEditingController controller;
  final Widget leading;

  const DecimalField({
    super.key,
    required this.label,
    required this.errors,
    required this.controller,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return BorderedFieldShell(
      label: label,
      errorText: errors.isNotEmpty ? errors.first.message : null,
      leading: leading,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.fieldPadding),
        ),
      ),
    );
  }
}
