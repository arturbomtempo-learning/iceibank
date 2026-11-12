import 'package:flutter/services.dart';

final List<TextInputFormatter> usernameInputFormatters = [
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
  TextInputFormatter.withFunction(
    (oldValue, newValue) => newValue.copyWith(text: newValue.text.toLowerCase()),
  ),
];
