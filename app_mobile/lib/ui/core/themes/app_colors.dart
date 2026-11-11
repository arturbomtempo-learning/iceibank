import 'package:flutter/cupertino.dart';

abstract final class AppColors {
  static const Color brand50 = Color(0xFFEBFBF4);
  static const Color brand100 = Color(0xFFCDF5E5);
  static const Color brand200 = Color(0xFF9CEAC9);
  static const Color brand300 = Color(0xFF61D9A8);
  static const Color brand400 = Color(0xFF2FC187);
  static const Color brand500 = Color(0xFF12A56E);
  static const Color brand600 = Color(0xFF0A8659);
  static const Color brand700 = Color(0xFF076B48);
  static const Color brand800 = Color(0xFF08543A);
  static const Color brand900 = Color(0xFF08422F);
  static const Color brand950 = Color(0xFF04211A);

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

  static const CupertinoDynamicColor surfaceSunken = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFEEF3F0),
    darkColor: Color(0xFF081813),
  );

  static const CupertinoDynamicColor border = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE3EAE6),
    darkColor: Color(0xFF1A2E28),
  );

  static const CupertinoDynamicColor borderStrong = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFD2DDD7),
    darkColor: Color(0xFF2A4438),
  );

  static const CupertinoDynamicColor text = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0B1F18),
    darkColor: Color(0xFFE7EFEB),
  );

  static const CupertinoDynamicColor textMuted = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF5F7369),
    darkColor: Color(0xFF93A9A0),
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

  static const CupertinoDynamicColor primaryLine = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF9CEAC9),
    darkColor: Color(0xFF1F4A3A),
  );

  static const CupertinoDynamicColor primaryInk = CupertinoDynamicColor.withBrightness(
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

  static const CupertinoDynamicColor inkMuted = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF8BB4A3),
    darkColor: Color(0xFF8FB4A3),
  );

  static const CupertinoDynamicColor inkLine = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF17452F),
    darkColor: Color(0xFF234638),
  );
}

extension ResolveColor on BuildContext {
  Color resolve(Color color) => CupertinoDynamicColor.resolve(color, this);
}
