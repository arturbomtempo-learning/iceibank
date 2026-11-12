import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/utils/currency.dart';

class AmountDisplay extends StatefulWidget {
  const AmountDisplay({
    super.key,
    required this.amountInCents,
    required this.isInvalid,
    required this.shakeSignal,
  });

  final int amountInCents;
  final bool isInvalid;
  final int shakeSignal;

  @override
  State<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<AmountDisplay> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(AmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeSignal != oldWidget.shakeSignal) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Color _color(BuildContext context) {
    if (widget.isInvalid) return context.resolve(AppColors.danger);
    if (widget.amountInCents == 0) return context.resolve(AppColors.textTertiary);
    return context.resolve(AppColors.text);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final text = formatCurrency(widget.amountInCents / 100);

    return Semantics(
      liveRegion: true,
      label: 'Valor: $text',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final progress = _shake.value;
            final offset = reduceMotion
                ? 0.0
                : math.sin(progress * math.pi * 6) * 10 * (1 - progress);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: TweenAnimationBuilder<double>(
            key: ValueKey(widget.amountInCents),
            tween: Tween(begin: reduceMotion ? 1 : 1.06, end: 1),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppTypography.amount(46).copyWith(color: _color(context)),
                child: Text(text, maxLines: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
