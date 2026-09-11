import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
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
///
/// Toda barra leva o próprio valor: são poucos dias por período, e a
/// altura relativa responde "qual foi o melhor" enquanto o rótulo
/// responde "quanto foi", que é o que o motorista veio ver.
class DailyProfitChart extends StatelessWidget {
  final List<DailyProfitEntry> entries;

  const DailyProfitChart({super.key, required this.entries});

  static const _plotHeight = 150.0;
  static const _barWidth = 24.0;
  static const _slotGap = 10.0;
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
              // Período sem nenhum dia no vermelho não reserva a faixa
              // de rótulo de baixo: seria uma tira vazia entre a linha do
              // zero e os dias.
              hasLoss: maxLoss > 0,
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
  final bool hasLoss;

  const _DayBar({
    required this.entry,
    required this.scale,
    required this.profitArea,
    required this.lossArea,
    required this.hasLoss,
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

    // As duas faixas de rótulo existem em toda coluna, mesmo vazias: é o
    // que mantém as linhas do zero e dos dias alinhadas entre colunas de
    // sinais diferentes.
    final label = _ValueLabel(
      value: entry.netProfit,
      color: semantic.forAmount(entry.netProfit),
    );

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
            child: isPositive ? label : null,
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
          SizedBox(
            height: hasLoss ? DailyProfitChart._labelHeight : 0,
            child: isPositive ? null : label,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            day,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)
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
}

class _ValueLabel extends StatelessWidget {
  final double value;
  final Color color;

  const _ValueLabel({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      // scaleDown, não contain: contain aumentaria os rótulos curtos pra
      // preencher a faixa, e cada barra ficaria com um tamanho de fonte
      // diferente do vizinho.
      fit: BoxFit.scaleDown,
      child: Text(
        value.formattedAmount,
        style: AppTextStyles.badgeStrong.copyWith(color: color).tabular,
      ),
    );
  }
}
