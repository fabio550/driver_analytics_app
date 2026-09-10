import 'package:driver_analytics_app/core/infrastructure/database/seed_data_provider.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();

    // Jornada em andamento sobrevive ao app fechar (fica persistida no
    // banco) — se o app reabre no meio de uma, é pra lá que o usuário
    // quer voltar, não pra home. Sem isso a jornada só reaparecia se o
    // usuário soubesse entrar em "Jornadas" e tocar no banner.
    Future.microtask(() async {
      await ref.read(activeShiftNotifierProvider.notifier).restore();
      if (!mounted) return;

      final activeShift = ref.read(activeShiftNotifierProvider).shift;
      if (activeShift != null) {
        context.push('/shifts/active');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Driver Analytics App')
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.push('/shifts');
                },
                child: Text('Jornadas')
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.push('/costs');
                },
                child: Text('Custos')
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.push('/earnings');
                },
                child: Text('Ganhos')
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.push('/analytics');
                },
                child: Text('Análises')
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _isSeeding ? null : _seedSampleData,
                  child: _isSeeding
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Popular dados de exemplo (debug)'),
                ),
              ],
            ],
          ),
        ),
      )
    );
  }

  Future<void> _seedSampleData() async {
    setState(() => _isSeeding = true);

    await ref.read(seedDataServiceProvider).seed();
    await ref.read(shiftNotifierProvider.notifier).loadShifts();
    await ref.read(costNotifierProvider.notifier).loadCosts();

    if (!mounted) return;
    setState(() => _isSeeding = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados de exemplo adicionados.')),
    );
  }
}
