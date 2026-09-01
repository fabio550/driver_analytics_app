import 'package:flutter/material.dart';

/// Paleta categórica pras séries de gráfico (fatias de breakdown, barras
/// rankeadas). Separada do ColorScheme do Material 3 de propósito: os 3
/// papéis de acento do tema (primary/secondary/tertiary) não dão
/// separação segura pra 5 categorias, e cor de série não pode colidir com
/// cor de status (erro, aviso). Validada pra daltonismo.
class AppChartColors {
  const AppChartColors._();

  static const _light = [
    Color(0xFF2A78D6),
    Color(0xFFEB6834),
    Color(0xFF1BAF7A),
    Color(0xFFEDA100),
    Color(0xFFE87BA4),
  ];

  static const _dark = [
    Color(0xFF3987E5),
    Color(0xFFD95926),
    Color(0xFF199E70),
    Color(0xFFC98500),
    Color(0xFFD55181),
  ];

  static List<Color> series(Brightness brightness) {
    return brightness == Brightness.dark ? _dark : _light;
  }

  static Color seriesAt(Brightness brightness, int index) {
    final palette = series(brightness);
    return palette[index % palette.length];
  }
}
