/// Escala de espaçamento do app. Use estes tokens em vez de números soltos
/// (`SizedBox(height: 16)`, `EdgeInsets.all(24)`...) em qualquer tela nova.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Padding horizontal interno dos campos com borda (BorderedFieldShell).
  static const double fieldPadding = 12;
}
