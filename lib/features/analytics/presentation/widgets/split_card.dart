import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SplitEntry {
  final String label;
  final double value;
  final String displayValue;
  final Color color;

  const SplitEntry({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.color,
  });
}

/// Decomposição em duas ou três fatias com um número de destaque em cima
/// (ex.: "31:48 · com passageiro · 67% do turno") — usado pelos cards de
/// tempo e distância da aba Operação. Mesma codificação de cor nos dois:
/// azul é produtivo, laranja é ocioso.
class SplitCard extends StatelessWidget {
  final String title;
  final String heroValue;
  final String heroQualifier;
  final List<SplitEntry> entries;
  final String? footnote;

  const SplitCard({
    super.key,
    required this.title,
    required this.heroValue,
    required this.heroQualifier,
    required this.entries,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = entries.fold<double>(0, (t, e) => t + e.value);

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  heroValue,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    heroQualifier,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (total <= 0)
              Text(
                'Sem dado no período.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  height: 22,
                  child: Row(
                    children: [
                      for (final entry in entries)
                        if (entry.value > 0)
                          Expanded(
                            flex: (entry.value * 1000).round().clamp(1, 1 << 30).toInt(),
                            child: Container(color: entry.color),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: entry.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child:
                            Text(entry.label, style: Theme.of(context).textTheme.bodySmall),
                      ),
                      Text(
                        entry.displayValue,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 42,
                        child: Text(
                          (entry.value / total).formattedPercent,
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
