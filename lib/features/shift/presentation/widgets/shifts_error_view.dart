import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';

class ShiftsErrorView extends ConsumerWidget {
  const ShiftsErrorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(shiftNotifierProvider).error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Não foi possível carregar os lançamentos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Erro desconhecido.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(shiftNotifierProvider.notifier).loadShifts();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
