import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/earning_row_tile.dart';
import 'package:flutter/material.dart';

/// Cartão de um turno com seus lançamentos — a lista principal da
/// EarningsPage é agrupada por turno, não por tipo, porque o que importa
/// aqui é ver o turno fechando ou não (checksum §6.3), e isso exige
/// corrida + promoção + ajuste juntos na mesma conta.
class ShiftEarningsGroup extends StatelessWidget {
  final DateTime shiftStartTime;
  final double? informedAmount;
  final List<EarningEntity> earnings;
  final void Function(EarningEntity earning)? onTapEarning;

  const ShiftEarningsGroup({
    super.key,
    required this.shiftStartTime,
    required this.informedAmount,
    required this.earnings,
    this.onTapEarning,
  });

  double get _sum => earnings.fold<double>(0, (total, e) => total + e.amount);

  bool get _isComplete {
    final informed = informedAmount;
    if (informed == null) return false;
    return (informed - _sum).abs() < 0.01;
  }

  String get _badgeLabel {
    if (_isComplete) return 'Completo';
    if (informedAmount == null) return 'Sem valor informado';
    return 'Faltam ${(informedAmount! - _sum).formattedCurrency}';
  }

  String get _footerText {
    if (_isComplete) return '${_sum.formattedCurrency} · bate com o informado';
    if (informedAmount == null) return '${_sum.formattedCurrency} lançados · sem valor informado';
    return '${_sum.formattedCurrency} de ${informedAmount!.formattedCurrency}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shiftStartTime.formattedFullDate,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        informedAmount != null
                            ? 'Informado ${informedAmount!.formattedCurrency}'
                            : 'Sem valor informado',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _CompletenessBadge(isComplete: _isComplete, label: _badgeLabel),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < earnings.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  EarningRowTile(
                    earning: earnings[i],
                    onTap: onTapEarning == null ? null : () => onTapEarning!(earnings[i]),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soma lançada',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        _footerText,
                        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletenessBadge extends StatelessWidget {
  final bool isComplete;
  final String label;

  const _CompletenessBadge({required this.isComplete, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isComplete ? colorScheme.primaryContainer : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.error_outline,
            size: 13,
            color: isComplete ? colorScheme.onPrimaryContainer : colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.badgeStrong.copyWith(
              color: isComplete ? colorScheme.onPrimaryContainer : colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}