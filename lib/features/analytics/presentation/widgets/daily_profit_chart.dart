import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_semantic_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';
import 'package:flutter/material.dart';

/// Barra por dia: sobe do zero quando o lucro do dia é positivo, desce
/// quando é negativo.
///
/// Uma escala só pros dois lados — a área acima e a abaixo da linha
/// dividem a altura na proporção do maior lucro e do maior prejuízo, em
/// vez de cada lado ter metade fixa. Com meia altura pra cada lado, um
/// prejuízo de R$ 10 desenhava do mesmo tamanho que um lucro de R$ 300.
class DailyProfitChart extends StatelessWidget {
  final List<DailyProfitEntry> entries;

  const DailyProfitChart({super.key, required this.entries});

  static const _plotHeight = 150.0;
  static const _barWidth = 24.0;
  static const _slotGap = 8.0;
  static const _labelHeight = 16.0;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SizedBox(
        height: _plotHeight,
        child: Center(
          child: Text(
            'Sem lançamentos no período.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    final maxProfit = entries
        .map((e) => e.netProfit)
        .fold<double>(0, (max, value) => value > max ? value : max);
    final maxLoss = entries
        .map((e) => -e.netProfit)
        .fold<double>(0, (max, value) => value > max ? value : max);

    final span = maxProfit + maxLoss;
    final profitArea = span > 0 ? _plotHeight * (maxProfit / span) : _plotHeight;
    final lossArea = _plotHeight - profitArea;
    final scale = span > 0 ? _plotHeight / span : 0.0;

    final best = entries.reduce((a, b) => a.netProfit > b.netProfit ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            _DayBar(
              entry: entry,
              scale: scale,
              profitArea: profitArea,
              lossArea: lossArea,
              isBest: identical(entry, best) && entry.netProfit > 0,
            ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final DailyProfitEntry entry;
  final double scale;
  final double profitArea;
  final double lossArea;
  final bool isBest;

  const _DayBar({
    required this.entry,
    required this.scale,
    required this.profitArea,
    required this.lossArea,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final isPositive = entry.netProfit >= 0;
    final barHeight = (entry.netProfit.abs() * scale).clamp(
      0.0,
      isPositive ? profitArea : lossArea,
    );

    final day = '${entry.date.day.toString().padLeft(2, '0')}/'
        '${entry.date.month.toString().padLeft(2, '0')}';

    return SizedBox(
      // A linha do zero é um traço de largura total dentro de cada
      // coluna: colunas encostadas fazem uma linha contínua, sem precisar
      // de um Stack por cima do gráfico.
      width: DailyProfitChart._barWidth + DailyProfitChart._slotGap * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: DailyProfitChart._labelHeight,
            child: isBest
                ? FittedBox(
                    child: Text(
                      _short(entry.netProfit),
                      style: AppTextStyles.badgeStrong
                          .copyWith(color: semantic.profit)
                          .tabular,
                    ),
                  )
                : null,
          ),
          SizedBox(
            height: profitArea,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _bar(isPositive ? barHeight : 0, AppChartColors.profit, true),
            ),
          ),
          // width: double.infinity porque a Column centraliza: uma caixa
          // colorida sem filho e sem largura assume 0px, e a linha do
          // zero sumia sem nenhum erro.
          SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: colorScheme.outlineVariant),
          ),
          SizedBox(
            height: lossArea,
            child: Align(
              alignment: Alignment.topCenter,
              child: _bar(isPositive ? 0 : barHeight, AppChartColors.loss, false),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            day,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(
                  color: isBest ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  fontWeight: isBest ? FontWeight.w700 : null,
                )
                .tabular,
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, Color color, bool growsUp) {
    const corner = Radius.circular(4);

    return Container(
      width: DailyProfitChart._barWidth,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: growsUp ? corner : Radius.zero,
          topRight: growsUp ? corner : Radius.zero,
          bottomLeft: growsUp ? Radius.zero : corner,
          bottomRight: growsUp ? Radius.zero : corner,
        ),
      ),
    );
  }

  String _short(double value) => value.toStringAsFixed(2).replaceAll('.', ',');
}
