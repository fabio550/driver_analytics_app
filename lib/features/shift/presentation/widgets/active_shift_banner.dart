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

    return Material(
      color: isPaused
          ? colorScheme.tertiaryContainer
          : colorScheme.primaryContainer,
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
                isPaused
                    ? Icons.pause_circle
                    : Icons.play_circle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPaused
                      ? 'Jornada pausada — toque para voltar'
                      : 'Jornada em andamento — toque para voltar',
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
