import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/presentation/widgets/bordered_field_shell.dart';
import 'package:flutter/material.dart';

class DateTimeField<TField> extends StatelessWidget {
  final String label;
  final DateTime? value;
  final List<ValidationFailure<TField>> errors;
  final VoidCallback onTap;

  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.errors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BorderedFieldShell(
      label: label,
      errorText: errors.isNotEmpty ? errors.first.message : null,
      leading: const Icon(Icons.date_range),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(value != null ? value!.formattedDDMMYYYYHHmm : 'Selecionar'),
      ),
    );
  }
}
