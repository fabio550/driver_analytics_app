import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_kind.dart';
import 'package:flutter/material.dart';

/// Pergunta qual tipo de ganho lançar. Diferente do FAB de Custos (que já
/// sabe a categoria pela aba ativa), aqui a lista é agrupada por turno,
/// não por tipo — não tem aba pra inferir, então o sheet pergunta.
class EarningKindSheet {
  static Future<EarningKind?> show(BuildContext context) {
    return showModalBottomSheet<EarningKind>(
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
                  'NOVO LANÇAMENTO',
                  style: AppTextStyles.eyebrow.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const _Option(
              kind: EarningKind.ride,
              title: 'Corrida',
              subtitle: 'Uma viagem específica',
            ),
            const _Option(
              kind: EarningKind.promotion,
              title: 'Promoção',
              subtitle: 'Quest, meta, incentivo',
            ),
            const _Option(
              kind: EarningKind.adjustment,
              title: 'Ajuste',
              subtitle: 'Correção feita pelo suporte',
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final EarningKind kind;
  final String title;
  final String subtitle;

  const _Option({required this.kind, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (kind) {
      EarningKind.ride => Icons.local_taxi,
      EarningKind.promotion => Icons.local_offer,
      EarningKind.adjustment => Icons.tune,
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
      onTap: () => Navigator.of(context).pop(kind),
    );
  }
}