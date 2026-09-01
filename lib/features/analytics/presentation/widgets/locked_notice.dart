import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Aviso de conteúdo travado — produtividade, ociosidade e ranking de
/// bairro só existem quando as jornadas do período fecham (ver
/// [CompletenessBanner]); mostrar esses números com dado furado seria pior
/// que não mostrar.
class LockedNotice extends StatelessWidget {
  final String message;

  const LockedNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
