import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';
import 'package:driver_analytics_app/features/analytics/presentation/extensions/cost_allocation_label_extension.dart';
import 'package:flutter/material.dart';

/// Detalhe de como o "custo atribuído (estimado)" foi montado — grupo
/// sem histórico suficiente cai pro próprio bruto (nunca trava o total
/// inteiro) e mostra a nota explicando por quê, em vez de fingir uma
/// taxa que não existe.
class CostAllocationBreakdownCard extends StatelessWidget {
  final CostAllocationResult allocation;

  const CostAllocationBreakdownCard({super.key, required this.allocation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'COMO O CUSTO ATRIBUÍDO FOI CALCULADO',
              style: AppTextStyles.eyebrow.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final group in allocation.groups)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.kind.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bruto: ${group.rawCost.formattedCurrency}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        Text(
                          group.isEstimated
                              ? 'Atribuído: ${group.attributedCost!.formattedCurrency}'
                              : 'Não estimado',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: group.isEstimated
                                    ? null
                                    : colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    if (group.note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          group.note!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
