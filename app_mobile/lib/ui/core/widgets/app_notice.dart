import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

enum AppNoticeTone { info, danger }

class AppNotice extends StatelessWidget {
  const AppNotice({super.key, required this.message, this.tone = AppNoticeTone.info});

  final String message;
  final AppNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final isDanger = tone == AppNoticeTone.danger;
    final foreground = context.resolve(isDanger ? AppColors.danger : AppColors.onPrimarySoft);

    return Semantics(
      liveRegion: isDanger,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.resolve(isDanger ? AppColors.dangerSoft : AppColors.primarySoft),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDanger
                  ? CupertinoIcons.exclamationmark_circle_fill
                  : CupertinoIcons.info_circle_fill,
              size: 18,
              color: foreground,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: AppTypography.subheadline.copyWith(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
