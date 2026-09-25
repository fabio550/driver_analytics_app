import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/earning/application/use_cases/ride_import_candidate.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:flutter/material.dart';

/// Uma corrida da prévia de importação. Duplicatas e tipos de serviço
/// não reconhecidos aparecem desabilitados, com o motivo explicado, em
/// vez de somem da lista — o usuário vê exatamente o que não entrou e
/// por quê, em vez de um total menor sem explicação.
class RideImportCandidateTile extends StatelessWidget {
  final RideImportCandidate candidate;
  final bool selected;
  final ValueChanged<bool?>? onChanged;

  const RideImportCandidateTile({
    super.key,
    required this.candidate,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = candidate.isRecognized
        ? candidate.serviceType!.label
        : candidate.serviceTypeRaw;

    final pickup = candidate.pickupGeo?.districtName;
    final destination = candidate.destinationGeo?.districtName;
    // ignore: use_null_aware_elements — a sintaxe `?pickup` ainda é
    // experimental no Dart estável (precisa de --enable-experiment),
    // então fica com o `if` até virar estável.
    final route = [
      if (pickup != null) pickup,
      if (destination != null) destination,
    ].join(' → ');

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: selected, onChanged: onChanged),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        candidate.fareBrl.formattedCurrency,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${candidate.occurredAt.formattedDDMMYYYYHHmm} · '
                    '${candidate.status.label}',
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (route.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      route,
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  if (!candidate.isRecognized) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _Badge(
                      label: 'Tipo de serviço não reconhecido',
                      color: colorScheme.errorContainer,
                      onColor: colorScheme.onErrorContainer,
                    ),
                  ] else if (candidate.isDuplicate) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _Badge(
                      label: 'Já importada antes',
                      color: colorScheme.surfaceContainerHigh,
                      onColor: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;

  const _Badge({required this.label, required this.color, required this.onColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: onColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
