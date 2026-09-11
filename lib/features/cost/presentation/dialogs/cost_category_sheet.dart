import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:flutter/material.dart';

/// Pergunta que tipo de custo lançar. Antes essa escolha vinha da aba
/// ativa da tela de Custos, e o FAB trocava de rótulo junto — o que
/// deixava dois padrões de criação diferentes no app (Ganhos já usava
/// sheet). Agora os dois lados de Lançamentos perguntam do mesmo jeito.
class CostCategorySheet {
  static Future<CostCategory?> show(BuildContext context) {
    return showModalBottomSheet<CostCategory>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NOVO CUSTO',
                  style: AppTextStyles.eyebrow.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const _Option(
              category: CostCategory.fuel,
              title: 'Abastecimento',
              subtitle: 'Combustível ou recarga',
            ),
            const _Option(
              category: CostCategory.maintenance,
              title: 'Manutenção',
              subtitle: 'Peça, revisão, pneu',
            ),
            const _Option(
              category: CostCategory.expense,
              title: 'Despesa',
              subtitle: 'Pedágio, lavagem, multa, outros',
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final CostCategory category;
  final String title;
  final String subtitle;

  const _Option({
    required this.category,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (category) {
      CostCategory.fuel => Icons.local_gas_station,
      CostCategory.maintenance => Icons.build,
      CostCategory.expense => Icons.receipt_long,
    };

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: () => Navigator.of(context).pop(category),
    );
  }
}
