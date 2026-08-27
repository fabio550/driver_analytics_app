import 'package:flutter/material.dart';

/// Cor semente única do app. Todo o resto da paleta (light e dark) é
/// derivado dela via [ColorScheme.fromSeed] em [AppTheme] — não declare
/// cores soltas em telas ou widgets, use `Theme.of(context).colorScheme`.
class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF2E5CFF);
}
