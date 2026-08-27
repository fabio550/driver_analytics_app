import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/bordered_field_shell.dart';
import 'package:flutter/material.dart';

class DateField<TField> extends StatelessWidget {
  final String label;
  final DateTime? value;
  final List<ValidationFailure<TField>> errors;
  final VoidCallback onTap;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.errors,
    required this.onTap,
  });

  /// Abre o date picker e devolve a data escolhida com a hora zerada, ou
  /// `null` se cancelado.
  static Future<DateTime?> pick(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }

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
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.fieldPadding),
        ),
        child: Text(value != null ? value!.formattedDDMMYYYY : 'Selecionar'),
      ),
    );
  }
}
