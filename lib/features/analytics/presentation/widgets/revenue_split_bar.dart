import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Barra do bruto dividida em lucro e custo. Responde "entrou quanto,
/// saiu quanto, sobrou quanto" de uma vez só — os três números existiam
/// antes como três cards iguais, sem relação visível entre eles.
///
/// Quando o custo passa o bruto a barra fica inteira de custo: não há
/// fatia de lucro pra desenhar, e o prejuízo aparece na legenda com
/// sinal e cor próprios.
class RevenueSplitBar extends StatelessWidget {
  final double revenue;
  final double cost;

  const RevenueSplitBar({super.key, required this.revenue, required this.cost});

  static const _barHeight = 10.0;
  static const _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    final profit = revenue - cost;
    final base = revenue > 0 ? revenue : cost;
    final profitFlex = base > 0 && profit > 0 ? (profit / base * 1000).round() : 0;
    final costFlex = base > 0 ? (cost.clamp(0, base) / base * 1000).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _barHeight,
          child: Row(
            children: [
              if (profitFlex > 0)
                Expanded(
                  flex: profitFlex,
                  child: _segment(
                    AppChartColors.profit,
                    leading: true,
                    trailing: costFlex == 0,
                  ),
                ),
              if (profitFlex > 0 && costFlex > 0) const SizedBox(width: _gap),
              if (costFlex > 0)
                Expanded(
                  flex: costFlex,
                  child: _segment(
                    AppChartColors.cost,
                    leading: profitFlex == 0,
                    trailing: true,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Wrap, não Row: com fonte grande por acessibilidade os dois
        // itens não cabem lado a lado, e um Row estouraria a largura.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _Legend(
              color: AppChartColors.profit,
              label: 'Lucro',
              value: profit.formattedCurrency,
            ),
            _Legend(
              color: AppChartColors.cost,
              label: 'Custos',
              value: cost.formattedCurrency,
            ),
          ],
        ),
      ],
    );
  }

  Widget _segment(Color color, {required bool leading, required bool trailing}) {
    const round = Radius.circular(_barHeight / 2);
    const square = Radius.circular(2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: leading ? round : square,
          bottomLeft: leading ? round : square,
          topRight: trailing ? round : square,
          bottomRight: trailing ? round : square,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.caption
              .copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700)
              .tabular,
        ),
      ],
    );
  }
}
