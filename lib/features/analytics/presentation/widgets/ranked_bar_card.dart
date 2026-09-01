import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class RankedItem {
  final String label;
  final double value;
  final String displayValue;

  const RankedItem({required this.label, required this.value, required this.displayValue});
}

/// Barras horizontais rankeadas — maior valor primeiro, largura da barra
/// proporcional ao maior item da lista.
class RankedBarCard extends StatelessWidget {
  final String title;
  final List<RankedItem> items;
  final Color barColor;
  final Widget? header;
  final String? footnote;

  const RankedBarCard({
    super.key,
    required this.title,
    required this.items,
    required this.barColor,
    this.header,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final max = items.isEmpty
        ? 0.0
        : items.map((i) => i.value).reduce((a, b) => a > b ? a : b);

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
            if (header != null) ...[
              const SizedBox(height: AppSpacing.sm),
              header!,
            ],
            const SizedBox(height: AppSpacing.sm),
            if (items.isEmpty)
              Text(
                'Sem lançamentos no período.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: SizedBox(
                            height: 14,
                            child: Stack(
                              children: [
                                Container(color: colorScheme.surfaceContainerHighest),
                                FractionallySizedBox(
                                  widthFactor: max > 0
                                      ? (item.value / max).clamp(0, 1).toDouble()
                                      : 0,
                                  child: Container(color: barColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 56,
                        child: Text(
                          item.displayValue,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
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
