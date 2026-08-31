import 'dart:math' as math;

import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:flutter/material.dart';

/// Borda que se desenha ao redor do [child] conforme [progress] (0 a 1),
/// começando no topo e girando no sentido horário. Usada em volta do
/// relógio da jornada ativa: como o tempo trabalhado só mostra HH:mm, a
/// borda é o que deixa visível que os segundos estão correndo — e ela
/// fecha exatamente quando o minuto vira.
class TimerProgressBorder extends StatelessWidget {
  final double progress;
  final Color color;
  final Color trackColor;
  final Widget child;
  final double strokeWidth;
  final double radius;
  final EdgeInsets padding;

  const TimerProgressBorder({
    super.key,
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.child,
    this.strokeWidth = 3,
    this.radius = AppRadius.lg,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TimerBorderPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color,
        trackColor: trackColor,
        strokeWidth: strokeWidth,
        radius: radius,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _TimerBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double radius;

  const _TimerBorderPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final bounds = (Offset.zero & size).deflate(inset);
    if (bounds.width <= 0 || bounds.height <= 0) return;

    final effectiveRadius = math.max(
      0.0,
      math.min(radius, math.min(bounds.width, bounds.height) / 2),
    );
    final path = _buildPath(bounds, effectiveRadius);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    if (progress <= 0) return;

    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  /// Retângulo arredondado montado à mão, e não via [Path.addRRect],
  /// porque o traço precisa começar no meio do topo — o addRRect começa
  /// depois do canto superior esquerdo.
  Path _buildPath(Rect bounds, double radius) {
    final centerX = bounds.center.dx;
    final corner = Radius.circular(radius);

    return Path()
      ..moveTo(centerX, bounds.top)
      ..lineTo(bounds.right - radius, bounds.top)
      ..arcToPoint(Offset(bounds.right, bounds.top + radius), radius: corner)
      ..lineTo(bounds.right, bounds.bottom - radius)
      ..arcToPoint(Offset(bounds.right - radius, bounds.bottom), radius: corner)
      ..lineTo(bounds.left + radius, bounds.bottom)
      ..arcToPoint(Offset(bounds.left, bounds.bottom - radius), radius: corner)
      ..lineTo(bounds.left, bounds.top + radius)
      ..arcToPoint(Offset(bounds.left + radius, bounds.top), radius: corner)
      ..lineTo(centerX, bounds.top);
  }

  @override
  bool shouldRepaint(_TimerBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}