import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Par rótulo/valor. [valueFirst] inverte a ordem: nas grades de métrica
/// dos cards o número vem primeiro, porque é ele que se lê de relance —
/// o rótulo só existe pra dizer de que número se trata.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final EdgeInsets padding;
  final bool valueFirst;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.padding = EdgeInsets.zero,
    this.valueFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final labelWidget = Text(
      label,
      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
    final valueWidget = Text(
      value,
      style: (valueFirst
              ? textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
              : textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))
          .tabular,
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: valueFirst
            ? [valueWidget, const SizedBox(height: 1), labelWidget]
            : [labelWidget, const SizedBox(height: 2), valueWidget],
      ),
    );
  }
}
