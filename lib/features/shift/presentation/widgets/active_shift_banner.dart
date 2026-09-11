import 'package:driver_analytics_app/core/presentation/theme/app_semantic_colors.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveShiftBanner extends StatelessWidget {
  final ShiftEntity shift;

  const ActiveShiftBanner({
    super.key,
    required this.shift,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = shift.isPaused;
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);

    return Material(
      // Pausa é um estado de atenção, não uma terceira cor de marca: o
      // âmbar é o mesmo do resto do app pra "isso está esperando você".
      color: isPaused ? semantic.warningContainer : colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => context.push('/shifts/active'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                isPaused ? Icons.pause_circle : Icons.play_circle,
                color: isPaused
                    ? semantic.onWarningContainer
                    : colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPaused
                      ? 'Jornada pausada — toque para voltar'
                      : 'Jornada em andamento — toque para voltar',
                  style: TextStyle(
                    color: isPaused
                        ? semantic.onWarningContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isPaused
                    ? semantic.onWarningContainer
                    : colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
