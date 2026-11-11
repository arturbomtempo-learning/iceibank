import 'package:flutter/cupertino.dart';

abstract final class AppTypography {
  static const String displayFamily = 'PlusJakartaSans';

  static TextStyle display(double size, {FontWeight weight = FontWeight.w800}) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      letterSpacing: size * -0.022,
      height: 1.12,
    );
  }

  static final TextStyle largeTitle = display(32);
  static final TextStyle title = display(26, weight: FontWeight.w700);
  static final TextStyle headline = display(17, weight: FontWeight.w700);
  static final TextStyle button = display(16, weight: FontWeight.w600);

  static const TextStyle body = TextStyle(fontSize: 16, height: 1.4);
  static const TextStyle callout = TextStyle(fontSize: 14, height: 1.4);
  static const TextStyle label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}
