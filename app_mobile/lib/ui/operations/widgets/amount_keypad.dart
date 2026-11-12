import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    this.enabled = true,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool enabled;

  static const List<List<int?>> _rows = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [null, 0, -1],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Row(
            children: [
              for (final key in row)
                Expanded(
                  child: switch (key) {
                    null => const SizedBox(height: AppSizes.control),
                    -1 => _KeypadButton(
                      semanticLabel: 'Apagar',
                      onPressed: enabled ? onBackspace : null,
                      onLongPress: enabled ? onClear : null,
                      child: Icon(
                        CupertinoIcons.delete_left,
                        size: 24,
                        color: context.resolve(AppColors.text),
                      ),
                    ),
                    _ => _KeypadButton(
                      semanticLabel: '$key',
                      onPressed: enabled ? () => onDigit(key) : null,
                      child: Text(
                        '$key',
                        style: AppTypography.title2.copyWith(
                          color: context.resolve(AppColors.text),
                        ),
                      ),
                    ),
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.semanticLabel,
    required this.onPressed,
    required this.child,
    this.onLongPress,
  });

  final String semanticLabel;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    final onLongPress = this.onLongPress;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.fromHeight(AppSizes.control + 4),
          pressedOpacity: 0.35,
          onPressed: onPressed == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed();
                },
          onLongPress: onLongPress == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onLongPress();
                },
          child: child,
        ),
      ),
    );
  }
}
