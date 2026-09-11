import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Corpo padrão de tela rolável: SafeArea + padding consistente. Não é
/// exclusivo de formulário — a jornada em andamento e as abas de análise
/// usam o mesmo corpo pra evitar bottom overflow quando o conteúdo (ou a
/// fonte, com escala de acessibilidade) passa da altura da tela.
///
/// A barra de rolagem só fica fixa no desktop. No celular ela era uma
/// barra de 10px sempre visível, com trilho: ocupava largura de conteúdo
/// e destoava do resto do sistema, onde a barra aparece ao rolar e some.
class ScreenScrollView extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  const ScreenScrollView({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  static bool get _isDesktop {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );

    return SafeArea(
      child: _isDesktop
          ? Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 10,
              interactive: true,
              child: scrollView,
            )
          : scrollView,
    );
  }
}
