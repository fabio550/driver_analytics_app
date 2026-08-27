import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Corpo padrão de tela de formulário: SafeArea + Scrollbar sempre visível
/// + padding consistente. Antes cada form (fuel/expense/maintenance/ride)
/// tinha sua própria versão desse scaffolding, com configs de Scrollbar
/// diferentes entre si (algumas nem tinham Scrollbar).
class FormScrollView extends StatelessWidget {
  final List<Widget> children;

  const FormScrollView({super.key, required this.children});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
