import 'package:flutter/cupertino.dart';

abstract final class AppTypography {
  static const String brandFamily = 'PlusJakartaSans';

  static TextStyle brand(double size, {FontWeight weight = FontWeight.w800}) {
    return TextStyle(
      fontFamily: brandFamily,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      letterSpacing: size * -0.022,
      height: 1.15,
    );
  }

  static final TextStyle largeTitle = brand(34);
  static final TextStyle title1 = brand(28, weight: FontWeight.w700);
  static final TextStyle title2 = brand(22, weight: FontWeight.w700);

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
  static const TextStyle body = TextStyle(fontSize: 17, letterSpacing: -0.4);
  static const TextStyle callout = TextStyle(fontSize: 16, letterSpacing: -0.3);
  static const TextStyle subheadline = TextStyle(fontSize: 15, letterSpacing: -0.2);
  static const TextStyle footnote = TextStyle(fontSize: 13, letterSpacing: -0.1);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}
