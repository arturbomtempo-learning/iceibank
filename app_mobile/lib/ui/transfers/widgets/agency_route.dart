import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AgencyRoute extends StatefulWidget {
  const AgencyRoute({super.key, required this.sourceAgency, required this.targetAgency});

  final int sourceAgency;
  final int? targetAgency;

  @override
  State<AgencyRoute> createState() => _AgencyRouteState();
}

class _AgencyRouteState extends State<AgencyRoute> with SingleTickerProviderStateMixin {
  static const double _nodeSize = 40;
  static const double _nodeCenterY = 58;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _description {
    final target = widget.targetAgency;
    if (target == null) return 'Digite a conta para ver o caminho da transferência.';
    if (target == widget.sourceAgency) {
      return 'Mesma agência: a Agência $target debita e credita na hora, em memória.';
    }
    return 'Entre agências: a Agência ${widget.sourceAgency} debita e envia o crédito '
        'para a Agência $target pela fila de mensagens.';
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: _description,
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  double centerX(int agency) =>
                      width * (2 * agency + 1) / (2 * AgencyEndpoints.count);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => CustomPaint(
                            painter: _RoutePainter(
                              from: Offset(centerX(widget.sourceAgency), _nodeCenterY),
                              to: widget.targetAgency == null
                                  ? null
                                  : Offset(centerX(widget.targetAgency!), _nodeCenterY),
                              progress: reduceMotion ? 1 : _controller.value,
                              lineColor: context.resolve(AppColors.textTertiary),
                              dotColor: context.resolve(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      for (final agency in AgencyEndpoints.ids)
                        Positioned(
                          left: centerX(agency) - 36,
                          top: _nodeCenterY - _nodeSize / 2,
                          width: 72,
                          child: _AgencyNode(
                            agency: agency,
                            role: agency == widget.sourceAgency
                                ? _NodeRole.source
                                : agency == widget.targetAgency
                                ? _NodeRole.target
                                : _NodeRole.idle,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                _description,
                key: ValueKey(_description),
                textAlign: TextAlign.center,
                style: AppTypography.footnote.copyWith(
                  color: context.resolve(AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NodeRole { source, target, idle }

class _AgencyNode extends StatelessWidget {
  const _AgencyNode({required this.agency, required this.role});

  final int agency;
  final _NodeRole role;

  @override
  Widget build(BuildContext context) {
    final primary = context.resolve(AppColors.primary);
    final (background, foreground, border) = switch (role) {
      _NodeRole.source => (primary, context.resolve(AppColors.onPrimary), primary),
      _NodeRole.target => (
        context.resolve(AppColors.primarySoft),
        context.resolve(AppColors.onPrimarySoft),
        primary,
      ),
      _NodeRole.idle => (
        context.resolve(AppColors.fill),
        context.resolve(AppColors.textTertiary),
        const Color(0x00000000),
      ),
    };

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: _AgencyRouteState._nodeSize,
          height: _AgencyRouteState._nodeSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(color: border, width: 2),
          ),
          child: Text(
            'A$agency',
            style: AppTypography.caption.copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          switch (role) {
            _NodeRole.source => 'Origem',
            _NodeRole.target => 'Destino',
            _NodeRole.idle => 'Agência $agency',
          },
          style: AppTypography.caption.copyWith(
            color: context.resolve(
              role == _NodeRole.idle ? AppColors.textTertiary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.lineColor,
    required this.dotColor,
  });

  final Offset from;
  final Offset? to;
  final double progress;
  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final target = to;
    if (target == null) return;

    final path = Path();
    if (target == from) {
      path.addOval(Rect.fromCircle(center: from.translate(0, -36), radius: 14));
    } else {
      final control = Offset((from.dx + target.dx) / 2, from.dy - 64);
      path
        ..moveTo(from.dx, from.dy - 20)
        ..quadraticBezierTo(control.dx, control.dy, target.dx, target.dy - 20);
    }

    final line = Paint()
      ..color = lineColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += 9) {
        canvas.drawPath(metric.extractPath(start, math.min(start + 4.5, metric.length)), line);
      }

      final tangent = metric.getTangentForOffset(
        metric.length * Curves.easeInOut.transform(progress),
      );
      if (tangent == null) continue;

      canvas
        ..drawCircle(tangent.position, 9, Paint()..color = dotColor.withValues(alpha: 0.18))
        ..drawCircle(tangent.position, 4.5, Paint()..color = dotColor);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.dotColor != dotColor;
  }
}
