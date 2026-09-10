/// Como um custo entra no total "atribuído" do período (usado em lucro
/// líquido / R$ por hora), em vez da soma bruta do que foi lançado — ver
/// [CostAllocationCalculator] em `analytics/domain/services`.
enum CostAllocationMethod {
  /// Taxa em R$/km, aplicada ao km rodado no período. Combustível e toda
  /// a árvore de manutenção.
  kmDriven,

  /// Taxa em R$/dia, aplicada aos dias do período. Financiamento, IPVA,
  /// seguro — custos recorrentes sem relação com km rodado.
  timeDriven,

  /// Soma bruta do período, sem suavização nenhuma — estacionamento,
  /// lavagem, multa, pedágio, outros.
  direct,
}
