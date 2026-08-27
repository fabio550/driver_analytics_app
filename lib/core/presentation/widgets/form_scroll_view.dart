import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Corpo padrão de tela de formulário: SafeArea + Scrollbar sempre visível
/// + padding consistente.
class FormScrollView extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  const FormScrollView({
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