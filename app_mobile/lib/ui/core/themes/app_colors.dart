import 'package:flutter/cupertino.dart';

abstract final class AppColors {
  static const Color brandLight = Color(0xFF2FC187);
  static const Color brand = Color(0xFF0A8659);
  static const Color brandDark = Color(0xFF08543A);
  static const Color accent = Color(0xFF57E3A8);
  static const Color white = Color(0xFFFFFFFF);

  static const CupertinoDynamicColor background = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF4F7F5),
    darkColor: Color(0xFF05110E),
  );

  static const CupertinoDynamicColor surface = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF0B1C17),
  );

  static const CupertinoDynamicColor fill = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFEFF3F1),
    darkColor: Color(0xFF15291F),
  );

  static const CupertinoDynamicColor text = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0B1F18),
    darkColor: Color(0xFFE7EFEB),
  );

  static const CupertinoDynamicColor textSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF5F7369),
    darkColor: Color(0xFF93A9A0),
  );

  static const CupertinoDynamicColor textTertiary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF8C9C94),
    darkColor: Color(0xFF6B8178),
  );

  static const CupertinoDynamicColor primary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0A8659),
    darkColor: Color(0xFF14B077),
  );

  static const CupertinoDynamicColor onPrimary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF04160F),
  );

  static const CupertinoDynamicColor primarySoft = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFEBFBF4),
    darkColor: Color(0xFF0F2C23),
  );

  static const CupertinoDynamicColor onPrimarySoft = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF08422F),
    darkColor: Color(0xFFB9EED6),
  );

  static const CupertinoDynamicColor danger = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFC6303D),
    darkColor: Color(0xFFF0707C),
  );

  static const CupertinoDynamicColor dangerSoft = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFDECEE),
    darkColor: Color(0xFF2D1519),
  );

  static const CupertinoDynamicColor ink = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF062017),
    darkColor: Color(0xFF0E241D),
  );

  static const CupertinoDynamicColor inkSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF8BB4A3),
    darkColor: Color(0xFF8FB4A3),
  );
}

extension ResolveColor on BuildContext {
  Color resolve(Color color) => CupertinoDynamicColor.resolve(color, this);
}
