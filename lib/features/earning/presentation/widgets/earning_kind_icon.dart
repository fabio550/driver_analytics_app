import 'package:driver_analytics_app/features/earning/domain/enums/earning_kind.dart';
import 'package:flutter/material.dart';

class EarningKindIcon extends StatelessWidget {
  final EarningKind kind;
  final double size;

  const EarningKindIcon({super.key, required this.kind, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (kind) {
      EarningKind.ride => Icons.local_taxi,
      EarningKind.promotion => Icons.local_offer,
      EarningKind.adjustment => Icons.tune,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.55, color: colorScheme.onPrimaryContainer),
    );
  }
}