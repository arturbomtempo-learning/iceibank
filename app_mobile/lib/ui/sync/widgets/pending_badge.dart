import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';

class PendingBadge extends StatelessWidget {
  const PendingBadge({super.key, this.size = 14, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      CupertinoIcons.clock,
      size: size,
      color: color ?? context.resolve(AppColors.textSecondary),
      semanticLabel: 'Pendente de sincronização',
    );
  }
}

class PendingSeal extends StatefulWidget {
  const PendingSeal({super.key, this.size = 96});

  final double size;

  @override
  State<PendingSeal> createState() => _PendingSealState();
}

class _PendingSealState extends State<PendingSeal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arcColor = context.resolve(AppColors.primary);

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.resolve(AppColors.fill),
            ),
          ),
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _ArcPainter(color: arcColor),
            ),
          ),
          PendingBadge(size: widget.size * 0.4, color: context.resolve(AppColors.text)),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color],
        stops: const [0.55, 1],
      ).createShader(Offset.zero & size);

    canvas.drawArc((Offset.zero & size).deflate(1.5), -math.pi / 2, math.pi * 1.4, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.color != color;
}
