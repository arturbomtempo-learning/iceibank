import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class QuickAction {
  const QuickAction({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final action in actions) Expanded(child: _QuickActionButton(action: action))],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      child: ExcludeSemantics(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: action.onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: context.resolve(AppColors.surface),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F062017), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: Icon(action.icon, size: 24, color: context.resolve(AppColors.primary)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.caption.copyWith(color: context.resolve(AppColors.text)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
