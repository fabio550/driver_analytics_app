import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:flutter/material.dart';

/// §checksum (rail item 3): o app não esconde jornada incompleta, ele diz
/// quanto falta em reais — a soma dos lançamentos é uma conta exata contra
/// o valor declarado ao finalizar.
class CompletenessBanner extends StatelessWidget {
  final ShiftCompleteness completeness;

  const CompletenessBanner({super.key, required this.completeness});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isComplete = completeness.isFullyComplete;

    final backgroundColor =
        isComplete ? colorScheme.primaryContainer : colorScheme.tertiaryContainer;
    final foregroundColor =
        isComplete ? colorScheme.onPrimaryContainer : colorScheme.onTertiaryContainer;

    final text = isComplete
        ? '${completeness.completeShifts} de ${completeness.totalShifts} jornadas completas.'
        : '${completeness.completeShifts} de ${completeness.totalShifts} jornadas completas. '
            'Faltam ${completeness.missingAmount!.formattedCurrency} em lançamentos '
            'pra bater com o total informado.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isComplete ? Icons.check_circle_outline : Icons.error_outline,
            color: foregroundColor,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: foregroundColor),
            ),
          ),
        ],
      ),
    );
  }
}
