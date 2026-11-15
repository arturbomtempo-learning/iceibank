import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';

abstract final class AppTheme {
  static CupertinoThemeData withBrightness(Brightness? brightness) {
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: AppColors.primary,
      primaryContrastingColor: AppColors.onPrimary,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: AppColors.background,
    );
  }
}
