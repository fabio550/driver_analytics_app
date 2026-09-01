import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/stat_tile.dart';
import 'package:flutter/material.dart';

class StatGridEntry {
  final String label;
  final String value;

  const StatGridEntry({required this.label, required this.value});
}

/// Card com título + grade de estatísticas (2 ou 3 colunas) — "Tempo",
/// "Ritmo", "Ticket médio", "Combustível" no design.
class StatGridCard extends StatelessWidget {
  final String title;
  final List<StatGridEntry> entries;
  final int columns;
  final String? footnote;

  const StatGridCard({
    super.key,
    required this.title,
    required this.entries,
    this.columns = 3,
    this.footnote,
  });

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
              title.toUpperCase(),
              style: AppTextStyles.eyebrow.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.6,
              children: [
                for (final entry in entries)
                  StatTile(label: entry.label, value: entry.value),
              ],
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
