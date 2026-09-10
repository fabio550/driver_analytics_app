import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
            ],
          ),
        ),
      )
    );
  }
}
