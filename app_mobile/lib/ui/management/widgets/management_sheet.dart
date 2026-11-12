import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class ManagementSheet extends StatelessWidget {
  const ManagementSheet({
    super.key,
    required this.title,
    required this.scrollController,
    required this.children,
    this.footer,
    this.canCancel = true,
    this.showTitle = true,
  });

  final String title;
  final ScrollController scrollController;
  final List<Widget> children;
  final Widget? footer;
  final bool canCancel;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    final background = context.resolve(AppColors.background);

    return CupertinoPageScaffold(
      backgroundColor: background,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: canCancel
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              )
            : null,
        middle: showTitle ? Text(title) : null,
        backgroundColor: background,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  AppSpacing.xl,
                ),
                children: children,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.md,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class SheetIntro extends StatelessWidget {
  const SheetIntro({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: context.resolve(AppColors.primarySoft),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Icon(icon, size: 26, color: context.resolve(AppColors.primary)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: AppTypography.title1.copyWith(color: context.resolve(AppColors.text))),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          style: AppTypography.subheadline.copyWith(
            color: context.resolve(AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class SheetSuccess extends StatelessWidget {
  const SheetSuccess({super.key, required this.title, required this.message, this.highlight});

  final String title;
  final String message;
  final Widget? highlight;

  @override
  Widget build(BuildContext context) {
    final highlight = this.highlight;

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.title1.copyWith(color: context.resolve(AppColors.text)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.subheadline.copyWith(
            color: context.resolve(AppColors.textSecondary),
          ),
        ),
        if (highlight != null) ...[const SizedBox(height: AppSpacing.xl), highlight],
      ],
    );
  }
}
