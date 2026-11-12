import 'package:flutter/services.dart';
import 'package:iceibank/utils/currency.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter({this.maxDigits = 9});

  final int maxDigits;

  static int centsFrom(String text) => int.tryParse(text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return TextEditingValue.empty;
    if (digits.length > maxDigits) return oldValue;

    final formatted = formatCurrency(int.parse(digits) / 100);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
