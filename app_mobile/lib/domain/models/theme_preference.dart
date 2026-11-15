import 'package:flutter/widgets.dart';

enum ThemePreference {
  system(storageValue: 'sistema', label: 'Automático', brightness: null),
  light(storageValue: 'claro', label: 'Claro', brightness: Brightness.light),
  dark(storageValue: 'escuro', label: 'Escuro', brightness: Brightness.dark);

  const ThemePreference({
    required this.storageValue,
    required this.label,
    required this.brightness,
  });

  final String storageValue;
  final String label;
  final Brightness? brightness;

  static ThemePreference fromStorage(String? value) {
    return values.firstWhere(
      (preference) => preference.storageValue == value,
      orElse: () => ThemePreference.system,
    );
  }
}
