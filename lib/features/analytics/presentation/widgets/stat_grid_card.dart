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
            // Linhas montadas à mão em vez de GridView.count: um
            // childAspectRatio fixo força a altura da célula por cálculo,
            // e rótulo/valor mais longos (ou fonte maior por acessibilidade)
            // estouravam essa altura — bottom overflow em cada tile. Row de
            // Expanded deixa a altura da linha ser a do conteúdo.
            for (final row in _chunk(entries, columns))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < columns; i++)
                      Expanded(
                        child: i < row.length
                            ? StatTile(label: row[i].label, value: row[i].value)
                            : const SizedBox.shrink(),
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

  List<List<StatGridEntry>> _chunk(List<StatGridEntry> entries, int size) {
    return [
      for (var i = 0; i < entries.length; i += size)
        entries.sublist(i, i + size > entries.length ? entries.length : i + size),
    ];
  }
}
