import 'package:driver_analytics_app/core/presentation/theme/app_semantic_colors.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cor primária', () {
    test('a semente vira um azul saturado, não o ardósia do tonalSpot', () {
      // A variante padrão (tonalSpot) resolvia #2E5CFF como #4F5B92.
      // Este teste existe pra a troca de variante não voltar sem querer.
      final primary = AppTheme.light.colorScheme.primary;

      expect(primary.b, greaterThan(0.78));
      expect(primary.r, lessThan(0.31));
    });
  });

  group('cores semânticas', () {
    test('estão registradas nos dois temas', () {
      expect(AppTheme.light.extension<AppSemanticColors>(), isNotNull);
      expect(AppTheme.dark.extension<AppSemanticColors>(), isNotNull);
    });

    test('valor negativo usa a cor de prejuízo, positivo a de lucro', () {
      const colors = AppSemanticColors.light;

      expect(colors.forAmount(-0.01), colors.loss);
      expect(colors.forAmount(0), colors.profit);
      expect(colors.forAmount(884.60), colors.profit);
    });
  });

  group('tokens do tema', () {
    test('Card lê AppRadius em vez do padrão do Material', () {
      final shape = AppTheme.light.cardTheme.shape as RoundedRectangleBorder;

      expect(shape.borderRadius, BorderRadius.circular(16));
    });
  });
}
