import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/utils/currency.dart';

void main() {
  test('formata valores no padrão brasileiro', () {
    expect(formatCurrency(0), r'R$ 0,00');
    expect(formatCurrency(2.5), r'R$ 2,50');
    expect(formatCurrency(800), r'R$ 800,00');
    expect(formatCurrency(1234.567), r'R$ 1.234,57');
    expect(formatCurrency(3750000), r'R$ 3.750.000,00');
    expect(formatCurrency(-45.9), r'-R$ 45,90');
  });
}
