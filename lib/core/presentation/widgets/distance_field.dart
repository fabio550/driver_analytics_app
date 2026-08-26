import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DistanceField<TField> extends StatelessWidget {
  final String label;
  final List<ValidationFailure<TField>> errors;
  final void Function(String)? onChanged;
  final TextEditingController controller;

  const DistanceField({
    super.key,
    required this.label,
    required this.errors,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
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
              child: const Icon(Icons.car_repair_sharp),
            ),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

