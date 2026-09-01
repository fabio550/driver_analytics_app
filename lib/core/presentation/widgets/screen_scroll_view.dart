import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Corpo padrão de tela rolável: SafeArea + Scrollbar sempre visível +
/// padding consistente. Não é exclusivo de formulário — active_shift_page
/// e as abas de análise usam o mesmo corpo pra evitar bottom overflow
/// quando o conteúdo (ou a fonte, com escala de acessibilidade) passa da
/// altura da tela.
class ScreenScrollView extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  const ScreenScrollView({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 10,
        interactive: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          ),
        ),
      ),
    );
  }
}
