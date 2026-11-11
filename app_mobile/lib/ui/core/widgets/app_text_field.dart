import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.errorText,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? errorText;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final borderColor = context.resolve(hasError ? AppColors.danger : AppColors.borderStrong);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.label.copyWith(color: context.resolve(AppColors.text))),
        const SizedBox(height: AppSpacing.sm),
        CupertinoTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          autocorrect: false,
          enableSuggestions: !obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: AppTypography.body.copyWith(color: context.resolve(AppColors.text)),
          placeholderStyle: AppTypography.body.copyWith(
            color: context.resolve(AppColors.textMuted).withValues(alpha: 0.7),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          decoration: BoxDecoration(
            color: context.resolve(enabled ? AppColors.surface : AppColors.surfaceSunken),
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(color: borderColor),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 15,
                color: context.resolve(AppColors.danger),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  errorText!,
                  style: AppTypography.caption.copyWith(color: context.resolve(AppColors.danger)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
