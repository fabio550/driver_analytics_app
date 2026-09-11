import 'package:flutter/material.dart';

/// Cores com significado financeiro — lucro, prejuízo e pendência.
///
/// O ColorScheme do Material 3 não tem papel pra "deu lucro" ou "deu
/// prejuízo": antes disso, lucro líquido negativo era desenhado em
/// `colorScheme.primary`, ou seja, azul. Cor nunca é o único sinal (o
/// sinal do número e o rótulo carregam junto), mas ela é o que faz o
/// motorista ler o card sem ler o número.
///
/// Não é uma paleta de gráfico: série de gráfico continua em
/// [AppChartColors], que tem outras restrições (separação entre fatias).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color profit;
  final Color profitContainer;
  final Color onProfitContainer;
  final Color loss;
  final Color lossContainer;
  final Color onLossContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  const AppSemanticColors({
    required this.profit,
    required this.profitContainer,
    required this.onProfitContainer,
    required this.loss,
    required this.lossContainer,
    required this.onLossContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  static const light = AppSemanticColors(
    profit: Color(0xFF0A6B49),
    profitContainer: Color(0xFFC2EFDB),
    onProfitContainer: Color(0xFF04452E),
    loss: Color(0xFFB3261E),
    lossContainer: Color(0xFFFFDAD6),
    onLossContainer: Color(0xFF93000A),
    warning: Color(0xFF855300),
    warningContainer: Color(0xFFFFDDB3),
    onWarningContainer: Color(0xFF2A1800),
  );

  static const dark = AppSemanticColors(
    profit: Color(0xFF7BD7B0),
    profitContainer: Color(0xFF08543A),
    onProfitContainer: Color(0xFFC2EFDB),
    loss: Color(0xFFFFB4AB),
    lossContainer: Color(0xFF93000A),
    onLossContainer: Color(0xFFFFDAD6),
    warning: Color(0xFFFFB95C),
    warningContainer: Color(0xFF5C3D00),
    onWarningContainer: Color(0xFFFFDDB3),
  );

  static AppSemanticColors of(BuildContext context) {
    return Theme.of(context).extension<AppSemanticColors>() ?? light;
  }

  /// Cor do texto de um valor monetário pelo sinal — o ponto único que
  /// decide "verde ou vermelho" em todo o app.
  Color forAmount(double amount) => amount < 0 ? loss : profit;

  @override
  AppSemanticColors copyWith({
    Color? profit,
    Color? profitContainer,
    Color? onProfitContainer,
    Color? loss,
    Color? lossContainer,
    Color? onLossContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return AppSemanticColors(
      profit: profit ?? this.profit,
      profitContainer: profitContainer ?? this.profitContainer,
      onProfitContainer: onProfitContainer ?? this.onProfitContainer,
      loss: loss ?? this.loss,
      lossContainer: lossContainer ?? this.lossContainer,
      onLossContainer: onLossContainer ?? this.onLossContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      profit: Color.lerp(profit, other.profit, t)!,
      profitContainer: Color.lerp(profitContainer, other.profitContainer, t)!,
      onProfitContainer: Color.lerp(onProfitContainer, other.onProfitContainer, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      lossContainer: Color.lerp(lossContainer, other.lossContainer, t)!,
      onLossContainer: Color.lerp(onLossContainer, other.onLossContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}
