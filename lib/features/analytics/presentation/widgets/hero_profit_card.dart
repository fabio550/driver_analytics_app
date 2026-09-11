import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_semantic_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/summary_analytics.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/revenue_split_bar.dart';
import 'package:flutter/material.dart';

/// Lucro líquido é o número herói — aparece só no Resumo (rail item 1):
/// se repetisse em Operação e Custos, uma conta de arredondamento
/// diferente faria as três divergirem e nenhuma seria confiável.
///
/// A barra logo abaixo dá o bruto e o custo que formaram esse número, e
/// é o que responde "entrou quanto, saiu quanto" sem sair da tela.
class HeroProfitCard extends StatelessWidget {
  final SummaryAnalytics summary;

  const HeroProfitCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semantic = AppSemanticColors.of(context);

    final context_ = [
      '${summary.shiftCount} ${summary.shiftCount == 1 ? 'jornada' : 'jornadas'}',
      summary.workedTime.formattedHHmm,
      summary.distanceKm.formattedKm,
    ].join(' · ');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          18,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lucro líquido',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              summary.netProfit.formattedCurrency,
              style: textTheme.displaySmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: semantic.forAmount(summary.netProfit),
                  )
                  .tabular,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context_,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)
                  .tabular,
            ),
            const SizedBox(height: AppSpacing.md),
            RevenueSplitBar(revenue: summary.revenue, cost: summary.cost),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ganho bruto ${summary.revenue.formattedCurrency}',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)
                  .tabular,
            ),
          ],
        ),
      ),
    );
  }
}
