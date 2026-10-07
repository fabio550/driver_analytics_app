import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/presentation/extensions/distance_range_label_extension.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/ranked_bar_card.dart';
import 'package:flutter/material.dart';

enum _RangeMetric { km, hora, qtd }

/// Lucratividade por faixa de distância, com métrica trocável — ao
/// contrário do ranking de bairros/tipo de serviço, as 4 faixas
/// ([DistanceRange]) NUNCA são reordenadas por valor: a leitura aqui é a
/// tendência ao longo da distância (corrida curta tende a pagar mais por
/// km por causa da tarifa mínima, viagem longa tende a pagar mais por
/// hora por ter menos tempo parado proporcional), que some se a ordem
/// virar um ranking.
class DistanceRangeRankingCard extends StatefulWidget {
  final List<DistanceRangeEntry> ranges;
  final Color barColor;

  const DistanceRangeRankingCard({super.key, required this.ranges, required this.barColor});

  @override
  State<DistanceRangeRankingCard> createState() => _DistanceRangeRankingCardState();
}

class _DistanceRangeRankingCardState extends State<DistanceRangeRankingCard> {
  _RangeMetric _metric = _RangeMetric.km;

  @override
  Widget build(BuildContext context) {
    // Ordem fixa de DistanceRange.values (curta -> viagem) — sem sort.
    final items = widget.ranges.map((r) {
      final value = switch (_metric) {
        _RangeMetric.km => r.revenuePerKm ?? 0.0,
        _RangeMetric.hora => r.revenuePerHour ?? 0.0,
        _RangeMetric.qtd => r.rideCount.toDouble(),
      };
      final display = switch (_metric) {
        _RangeMetric.km => r.revenuePerKm.formattedCurrencyOrDash,
        _RangeMetric.hora => r.revenuePerHour.formattedCurrencyOrDash,
        _RangeMetric.qtd => '${r.rideCount}',
      };
      return RankedItem(label: r.range.label, value: value, displayValue: display);
    }).toList();

    return RankedBarCard(
      title: 'Faixa de distância',
      items: items,
      barColor: widget.barColor,
      header: SegmentedButton<_RangeMetric>(
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: const [
          ButtonSegment(value: _RangeMetric.km, label: Text('R\$/km')),
          ButtonSegment(value: _RangeMetric.hora, label: Text('R\$/hora')),
          ButtonSegment(value: _RangeMetric.qtd, label: Text('Corridas')),
        ],
        selected: {_metric},
        onSelectionChanged: (selection) => setState(() => _metric = selection.first),
      ),
      footnote: 'Curta: até 3 km · Média: 3–8 km · Longa: 8–20 km · Viagem: '
          'acima de 20 km. Faixas fixas (não reordenam por valor) pra revelar '
          'a tendência ao longo da distância.',
    );
  }
}
