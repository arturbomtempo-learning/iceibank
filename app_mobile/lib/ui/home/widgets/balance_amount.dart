import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/utils/currency.dart';

class BalanceAmount extends StatelessWidget {
  const BalanceAmount({
    super.key,
    required this.amount,
    required this.isVisible,
    required this.style,
  });

  final double amount;
  final bool isVisible;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: isVisible
          ? TweenAnimationBuilder<double>(
              key: ValueKey(amount),
              tween: Tween(begin: 0, end: amount),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(formatCurrency(value), style: style),
            )
          : Semantics(
              label: 'Saldo oculto',
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    'R\$ ••••••',
                    key: const ValueKey('hidden'),
                    style: style.copyWith(
                      color: style.color?.withValues(alpha: 0.4),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      fontVariations: const [FontVariation.weight(600)],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class BalanceVisibilityButton extends StatelessWidget {
  const BalanceVisibilityButton({
    super.key,
    required this.isVisible,
    required this.onPressed,
    required this.color,
  });

  final bool isVisible;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isVisible ? 'Ocultar saldo' : 'Mostrar saldo',
      child: ExcludeSemantics(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(AppSizes.minTapTarget),
          onPressed: onPressed,
          child: Icon(
            isVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            size: 22,
            color: color,
          ),
        ),
      ),
    );
  }
}
