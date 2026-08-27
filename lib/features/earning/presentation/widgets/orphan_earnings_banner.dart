import 'package:flutter/material.dart';

/// Banner fixo pros ganhos sem jornada (§6.2) — sempre visível no topo,
/// nunca escondido numa aba, porque resolver isso é o que desbloqueia o
/// checksum de completude de um turno.
class OrphanEarningsBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const OrphanEarningsBanner({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.help_outline, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count ${count == 1 ? 'lançamento sem jornada' : 'lançamentos sem jornada'}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Toque pra atribuir a um turno',
                      style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}