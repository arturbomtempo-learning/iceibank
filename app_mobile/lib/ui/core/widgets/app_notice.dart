import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

enum AppNoticeTone { brand, danger }

class AppNotice extends StatelessWidget {
  const AppNotice({super.key, required this.message, this.tone = AppNoticeTone.brand});

  final String message;
  final AppNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final isDanger = tone == AppNoticeTone.danger;
    final foreground = context.resolve(isDanger ? AppColors.danger : AppColors.primaryInk);

    return Semantics(
      liveRegion: isDanger,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.resolve(isDanger ? AppColors.dangerSoft : AppColors.primarySoft),
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(
            color: context.resolve(isDanger ? AppColors.danger : AppColors.primaryLine),
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDanger ? CupertinoIcons.exclamationmark_triangle : CupertinoIcons.info_circle,
              size: 18,
              color: foreground,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: AppTypography.callout.copyWith(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
