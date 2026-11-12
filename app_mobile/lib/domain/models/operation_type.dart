enum OperationType {
  deposit(
    title: 'Depositar',
    path: 'depositar',
    successTitle: 'Depósito realizado',
    loadingLabel: 'Depositando',
    accountLabel: 'Conta de destino',
  ),
  withdraw(
    title: 'Sacar',
    path: 'sacar',
    successTitle: 'Saque realizado',
    loadingLabel: 'Sacando',
    accountLabel: 'Conta de origem',
  );

  const OperationType({
    required this.title,
    required this.path,
    required this.successTitle,
    required this.loadingLabel,
    required this.accountLabel,
  });

  final String title;
  final String path;
  final String successTitle;
  final String loadingLabel;
  final String accountLabel;

  double apply(double balance, double amount) {
    return this == deposit ? balance + amount : balance - amount;
  }
}
