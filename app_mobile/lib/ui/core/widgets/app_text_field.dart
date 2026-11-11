import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.errorText,
    this.focusNode,
    this.isPassword = false,
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
  final bool isPassword;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownFocusNode;
  bool _isObscured = true;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _toggleVisibility() => setState(() => _isObscured = !_isObscured);

  Color _borderColor(BuildContext context) {
    if (widget.errorText != null) return context.resolve(AppColors.danger);
    if (_focusNode.hasFocus) return context.resolve(AppColors.primary);
    return const Color(0x00000000);
  }

  @override
  Widget build(BuildContext context) {
    final errorText = widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: AppTypography.footnote.copyWith(
            color: context.resolve(AppColors.textSecondary),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: AppSizes.control),
          decoration: BoxDecoration(
            color: context.resolve(AppColors.fill),
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: _borderColor(context), width: 1.5),
          ),
          child: CupertinoTextField(
            controller: widget.controller,
            focusNode: _focusNode,
            placeholder: widget.placeholder,
            obscureText: widget.isPassword && _isObscured,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            clearButtonMode: widget.isPassword
                ? OverlayVisibilityMode.never
                : OverlayVisibilityMode.editing,
            suffix: widget.isPassword
                ? _VisibilityToggle(isObscured: _isObscured, onPressed: _toggleVisibility)
                : null,
            style: AppTypography.body.copyWith(color: context.resolve(AppColors.text)),
            placeholderStyle: AppTypography.body.copyWith(
              color: context.resolve(AppColors.textTertiary),
            ),
            cursorColor: context.resolve(AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: null,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorText,
            style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.danger)),
          ),
        ],
      ],
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.isObscured, required this.onPressed});

  final bool isObscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isObscured ? 'Mostrar senha' : 'Ocultar senha',
      child: ExcludeSemantics(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(AppSizes.minTapTarget),
          onPressed: onPressed,
          child: Icon(
            isObscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            size: 20,
            color: context.resolve(AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
