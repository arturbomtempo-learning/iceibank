import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final foreground = context.resolve(AppColors.onPrimary);

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        color: context.resolve(AppColors.primary),
        disabledColor: context.resolve(AppColors.primary).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.base),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              CupertinoActivityIndicator(color: foreground, radius: 9),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              isLoading ? (loadingLabel ?? label) : label,
              style: AppTypography.button.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
