String formatCurrency(num value) {
  final cents = (value * 100).round();
  final digits = (cents.abs() ~/ 100).toString();
  final decimals = (cents.abs() % 100).toString().padLeft(2, '0');

  final grouped = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) grouped.write('.');
    grouped.write(digits[index]);
  }

  final sign = cents < 0 ? '-' : '';
  return '${sign}R\$ $grouped,$decimals';
}
