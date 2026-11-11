import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';

abstract final class AppTheme {
  static const CupertinoThemeData data = CupertinoThemeData(
    primaryColor: AppColors.primary,
    primaryContrastingColor: AppColors.onPrimary,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.background,
  );
}
