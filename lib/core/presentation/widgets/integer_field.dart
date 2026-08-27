import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/bordered_field_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerField<TField> extends StatelessWidget {
  final String label;
  final List<ValidationFailure<TField>> errors;
  final TextEditingController controller;
  final Widget leading;

  const IntegerField({
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
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.fieldPadding),
        ),
      ),
    );
  }
}
