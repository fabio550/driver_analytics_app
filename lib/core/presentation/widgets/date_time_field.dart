import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
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
            border: Border.all(
              color: const Color(0xFFE0DED8),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Color(0xFFE0DED8),
                    ),
                  ),
                ),
                child: Icon(Icons.date_range),
              ),
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(value != null ? value!.formattedHHmm : 'Selecionar'),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
