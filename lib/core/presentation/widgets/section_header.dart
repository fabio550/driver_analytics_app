import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Rótulo de seção em caixa alta com um complemento opcional à direita
/// (total do mês, "ver todas"). Usado no Início, em Jornadas e em
/// Lançamentos pra as três listas terem o mesmo cabeçalho.
class SectionHeader extends StatelessWidget {
  final String label;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.label,
    this.trailingText,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trailing = trailingText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.eyebrow.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (trailing != null)
            if (onTrailingTap != null)
              InkWell(
                onTap: onTrailingTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailing,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: colorScheme.primary),
                    ],
                  ),
                ),
              )
            else
              Text(
                trailing,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ).tabular,
              ),
        ],
      ),
    );
  }
}
