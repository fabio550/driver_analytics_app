import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
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
  /// `null` se cancelado. Método estático porque a lógica não depende de
  /// nada além do valor atual — reaproveitado nas 3 telas de Custo.
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
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          errorText: errors.isNotEmpty ? errors.first.message : null,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: borderColor)),
                ),
                child: const Icon(Icons.date_range),
              ),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    value != null ? value!.formattedDDMMYYYY : 'Selecionar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}