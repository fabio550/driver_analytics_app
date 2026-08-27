import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            ],
          ),
        ),
      )
    );
  }
}
