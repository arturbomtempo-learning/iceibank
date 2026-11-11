import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

enum AppLogoVariant { onLight, onInk }

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.onLight,
    this.markSize = 34,
    this.markOnly = false,
  });

  final AppLogoVariant variant;
  final double markSize;
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(size: Size.square(markSize), painter: const _LogoMarkPainter());

    if (markOnly) {
      return Semantics(label: 'ICEIBank', child: mark);
    }

    final isOnInk = variant == AppLogoVariant.onInk;
    final textStyle = AppTypography.brand(markSize * 0.62)
        .copyWith(color: isOnInk ? AppColors.white : context.resolve(AppColors.text));

    return Semantics(
      label: 'ICEIBank',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            SizedBox(width: markSize * 0.3),
            Text.rich(
              TextSpan(
                text: 'ICEI',
                children: [
                  TextSpan(
                    text: 'Bank',
                    style: TextStyle(
                      color: isOnInk ? AppColors.accent : context.resolve(AppColors.primary),
                    ),
                  ),
                ],
              ),
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  const _LogoMarkPainter();

  static const double _viewBox = 40;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);

    const square = Rect.fromLTWH(0, 0, _viewBox, _viewBox);
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.brandLight, AppColors.brand, AppColors.brandDark],
        stops: [0, 0.55, 1],
      ).createShader(square);
    canvas.drawRRect(RRect.fromRectAndRadius(square, const Radius.circular(12)), background);

    canvas
      ..translate(_viewBox / 2, _viewBox / 2)
      ..rotate(-math.pi / 4)
      ..translate(-_viewBox / 2, -_viewBox / 2);

    const bars = [
      (rect: Rect.fromLTWH(8, 9.6, 24, 4.6), opacity: 1.0),
      (rect: Rect.fromLTWH(11, 17.7, 18, 4.6), opacity: 0.82),
      (rect: Rect.fromLTWH(14, 25.8, 12, 4.6), opacity: 0.6),
    ];

    for (final bar in bars) {
      final paint = Paint()..color = AppColors.white.withValues(alpha: bar.opacity);
      canvas.drawRRect(RRect.fromRectAndRadius(bar.rect, const Radius.circular(2.3)), paint);
    }
  }

  @override
  bool shouldRepaint(_LogoMarkPainter oldDelegate) => false;
}
