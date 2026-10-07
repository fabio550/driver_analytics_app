import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/ranked_bar_card.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:flutter/material.dart';

enum _ServiceTypeMetric { km, hora, qtd }

/// Lucratividade por tipo de serviço (Uber X, Comfort, Black...), com
/// métrica trocável. Ao contrário da faixa de distância, não existe uma
/// ordem natural entre os tipos — ordena pela métrica escolhida, igual ao
/// ranking de bairros.
class ServiceTypeRankingCard extends StatefulWidget {
  final List<ServiceTypeEntry> serviceTypes;
  final Color barColor;

  const ServiceTypeRankingCard({
    super.key,
    required this.serviceTypes,
    required this.barColor,
  });

  @override
  State<ServiceTypeRankingCard> createState() => _ServiceTypeRankingCardState();
}

class _ServiceTypeRankingCardState extends State<ServiceTypeRankingCard> {
  _ServiceTypeMetric _metric = _ServiceTypeMetric.km;

  @override
  Widget build(BuildContext context) {
    final ranked = [...widget.serviceTypes]..sort((a, b) {
        return switch (_metric) {
          _ServiceTypeMetric.km => (b.revenuePerKm ?? 0).compareTo(a.revenuePerKm ?? 0),
          _ServiceTypeMetric.hora =>
            (b.revenuePerHour ?? 0).compareTo(a.revenuePerHour ?? 0),
          _ServiceTypeMetric.qtd => b.rideCount.compareTo(a.rideCount),
        };
      });

    final items = ranked.take(5).map((s) {
      final value = switch (_metric) {
        _ServiceTypeMetric.km => s.revenuePerKm ?? 0.0,
        _ServiceTypeMetric.hora => s.revenuePerHour ?? 0.0,
        _ServiceTypeMetric.qtd => s.rideCount.toDouble(),
      };
      final display = switch (_metric) {
        _ServiceTypeMetric.km => s.revenuePerKm.formattedCurrencyOrDash,
        _ServiceTypeMetric.hora => s.revenuePerHour.formattedCurrencyOrDash,
        _ServiceTypeMetric.qtd => '${s.rideCount}',
      };
      return RankedItem(label: s.serviceType.label, value: value, displayValue: display);
    }).toList();

    return RankedBarCard(
      title: 'Tipo de serviço',
      items: items,
      barColor: widget.barColor,
      header: SegmentedButton<_ServiceTypeMetric>(
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: const [
          ButtonSegment(value: _ServiceTypeMetric.km, label: Text('R\$/km')),
          ButtonSegment(value: _ServiceTypeMetric.hora, label: Text('R\$/hora')),
          ButtonSegment(value: _ServiceTypeMetric.qtd, label: Text('Corridas')),
        ],
        selected: {_metric},
        onSelectionChanged: (selection) => setState(() => _metric = selection.first),
      ),
      footnote: switch (_metric) {
        _ServiceTypeMetric.km => 'Receita da corrida dividida pelos km com passageiro.',
        _ServiceTypeMetric.hora =>
          'Receita dividida pelo tempo da corrida, incluindo trânsito parado.',
        _ServiceTypeMetric.qtd => 'Volume de corridas — não é o mesmo que onde paga melhor.',
      },
    );
  }
}
