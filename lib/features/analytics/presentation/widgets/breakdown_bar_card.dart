import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BreakdownItem {
  final String label;
  final double amount;
  final Color color;

  const BreakdownItem({required this.label, required this.amount, required this.color});
}

/// Barra empilhada horizontal + legenda — "de onde veio"/"pra onde foi o
/// dinheiro". Valor e percentual ficam escritos do lado do nome: a leitura
/// nunca depende só de identificar a cor da fatia.
class BreakdownBarCard extends StatelessWidget {
  final String title;
  final List<BreakdownItem> items;
  final String? footnote;

  const BreakdownBarCard({
    super.key,
    required this.title,
    required this.items,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = items.fold<double>(0, (t, i) => t + i.amount);
    final visibleItems = items.where((i) => i.amount > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.eyebrow.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (visibleItems.isEmpty || total <= 0)
              Text(
                'Sem lançamentos no período.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  height: 22,
                  child: Row(
                    children: [
                      for (final item in visibleItems)
                        Expanded(
                          flex: (item.amount * 1000).round().clamp(1, 1 << 30).toInt(),
                          child: Container(color: item.color),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final item in visibleItems)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                      ),
                      Text(
                        item.amount.formattedCurrency,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 42,
                        child: Text(
                          (item.amount / total).formattedPercent,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (footnote != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Divider(color: colorScheme.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                footnote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
