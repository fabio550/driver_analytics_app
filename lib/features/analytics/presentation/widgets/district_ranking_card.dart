import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/ranked_bar_card.dart';
import 'package:flutter/material.dart';

enum _DistrictMetric { km, hora, qtd }

/// Ranking de bairro de embarho com métrica trocável — R$/km revela onde
/// vale rodar por distância, R$/hora onde vale rodar por tempo (ordem
/// diferente: km parado no trânsito custa hora mas não custa km rodado).
class DistrictRankingCard extends StatefulWidget {
  final List<DistrictEntry> districts;
  final Color barColor;

  const DistrictRankingCard({super.key, required this.districts, required this.barColor});

  @override
  State<DistrictRankingCard> createState() => _DistrictRankingCardState();
}

class _DistrictRankingCardState extends State<DistrictRankingCard> {
  _DistrictMetric _metric = _DistrictMetric.km;

  @override
  Widget build(BuildContext context) {
    final ranked = [...widget.districts]..sort((a, b) {
        return switch (_metric) {
          _DistrictMetric.km => (b.revenuePerKm ?? 0).compareTo(a.revenuePerKm ?? 0),
          _DistrictMetric.hora => (b.revenuePerHour ?? 0).compareTo(a.revenuePerHour ?? 0),
          _DistrictMetric.qtd => b.rideCount.compareTo(a.rideCount),
        };
      });

    final items = ranked.take(5).map((d) {
      final value = switch (_metric) {
        _DistrictMetric.km => d.revenuePerKm ?? 0.0,
        _DistrictMetric.hora => d.revenuePerHour ?? 0.0,
        _DistrictMetric.qtd => d.rideCount.toDouble(),
      };
      final display = switch (_metric) {
        _DistrictMetric.km => d.revenuePerKm.formattedCurrencyOrDash,
        _DistrictMetric.hora => d.revenuePerHour.formattedCurrencyOrDash,
        _DistrictMetric.qtd => '${d.rideCount}',
      };
      return RankedItem(label: d.districtId, value: value, displayValue: display);
    }).toList();

    return RankedBarCard(
      title: 'Bairros de embarque',
      items: items,
      barColor: widget.barColor,
      header: SegmentedButton<_DistrictMetric>(
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: const [
          ButtonSegment(value: _DistrictMetric.km, label: Text('R\$/km')),
          ButtonSegment(value: _DistrictMetric.hora, label: Text('R\$/hora')),
          ButtonSegment(value: _DistrictMetric.qtd, label: Text('Corridas')),
        ],
        selected: {_metric},
        onSelectionChanged: (selection) => setState(() => _metric = selection.first),
      ),
      footnote: switch (_metric) {
        _DistrictMetric.km =>
          'Receita da corrida dividida pelos km com passageiro.',
        _DistrictMetric.hora =>
          'Receita dividida pelo tempo da corrida, incluindo trânsito parado.',
        _DistrictMetric.qtd =>
          'Volume de embarques — não é o mesmo que onde paga melhor.',
      },
    );
  }
}
