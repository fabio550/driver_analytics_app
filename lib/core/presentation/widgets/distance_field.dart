import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/presentation/widgets/bordered_field_shell.dart';
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
    return BorderedFieldShell(
      label: label,
      errorText: errors.isNotEmpty ? errors.first.message : null,
      leading: const Icon(Icons.car_repair_sharp),
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
