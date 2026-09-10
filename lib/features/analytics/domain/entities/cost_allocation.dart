import 'package:driver_analytics_app/features/cost/domain/enums/cost_allocation_method.dart';

/// Cada uma das 6 fatias em que o custo do período é decomposto —
/// granularidade mais fina que [CostAllocationMethod] porque combustível
/// e manutenção usam janelas diferentes entre si, e financiamento/IPVA/
/// seguro precisam de nota individual quando faltar dado.
enum CostAllocationGroupKind {
  fuel,
  maintenance,
  financing,
  taxes,
  insurance,
  direct,
}

/// Uma fatia do custo do período: quanto foi gasto de verdade
/// ([rawCost], sempre disponível) e quanto entra na conta de lucro
/// líquido depois de suavizado ([attributedCost] — `null` só quando não
/// há histórico suficiente pra confiar numa taxa; ausência real do custo
/// é `0`, não `null`).
class CostAllocationGroup {
  final CostAllocationGroupKind kind;
  final CostAllocationMethod method;
  final double rawCost;
  final double? attributedCost;

  /// Texto de transparência pra UI — por que a taxa é a que é (ex.: "taxa
  /// baseada nos últimos 3 meses") ou por que não foi possível calcular.
  final String? note;

  const CostAllocationGroup({
    required this.kind,
    required this.method,
    required this.rawCost,
    required this.attributedCost,
    this.note,
  });

  /// O que efetivamente entra no total atribuído: a taxa suavizada
  /// quando existe, senão o bruto do próprio grupo — nunca bloqueia o
  /// total inteiro por causa de uma fatia sem histórico (rateio § "opção
  /// b": trava por grupo, não tudo-ou-nada).
  double get effectiveCost => attributedCost ?? rawCost;

  bool get isEstimated => attributedCost != null;
}

class CostAllocationResult {
  final List<CostAllocationGroup> groups;

  /// "Gasto no período" — soma bruta real do que foi lançado, sem taxa.
  final double rawTotal;

  /// "Custo atribuído (estimado)" — o que entra em lucro líquido/R$ por
  /// hora. Nunca nulo: cada grupo cai pro próprio bruto quando não tem
  /// dado suficiente pra taxa.
  final double attributedTotal;

  /// Falso quando algum grupo km/time-driven ainda não tem histórico
  /// suficiente — todo grupo `direct` é ignorado aqui, já que nunca tem
  /// taxa mesmo.
  final bool isFullyEstimated;

  const CostAllocationResult({
    required this.groups,
    required this.rawTotal,
    required this.attributedTotal,
    required this.isFullyEstimated,
  });

  static const empty = CostAllocationResult(
    groups: [],
    rawTotal: 0,
    attributedTotal: 0,
    isFullyEstimated: true,
  );
}
