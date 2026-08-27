import 'package:flutter/material.dart';

/// Casca visual compartilhada por todo campo com prefixo (ícone/texto) +
/// borda — CurrencyField, DistanceField, DecimalField, DateField,
/// DateTimeField. A cor da borda mora só aqui: antes, cada campo tinha
/// sua própria cópia, e uma correção de tema escuro passou batido em 3
/// das 5.
class BorderedFieldShell extends StatelessWidget {
  final String label;
  final String? errorText;
  final Widget leading;
  final Widget child;
  final VoidCallback? onTap;

  const BorderedFieldShell({
    super.key,
    required this.label,
    required this.errorText,
    required this.leading,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    final field = InputDecorator(
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: label,
        errorText: errorText,
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
              child: leading,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );

    if (onTap == null) return field;
    return InkWell(onTap: onTap, child: field);
  }
}
