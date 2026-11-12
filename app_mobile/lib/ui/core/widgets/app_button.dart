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
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final foreground = context.resolve(AppColors.onPrimary);
    final primary = context.resolve(AppColors.primary);
    final isDisabled = onPressed == null && !isLoading;

    return Semantics(
      button: true,
      label: label,
      enabled: !isLoading && onPressed != null,
      child: ExcludeSemantics(
        child: SizedBox(
          width: double.infinity,
          height: AppSizes.control,
          child: CupertinoButton(
            onPressed: isLoading ? null : onPressed,
            color: primary,
            disabledColor: isDisabled ? primary.withValues(alpha: 0.35) : primary,
            borderRadius: BorderRadius.circular(AppRadius.control),
            padding: EdgeInsets.zero,
            child: isLoading
                ? CupertinoActivityIndicator(color: foreground)
                : Text(label, style: AppTypography.headline.copyWith(color: foreground)),
          ),
        ),
      ),
    );
  }
}
