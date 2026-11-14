enum OperationType {
  deposit(
    title: 'Depositar',
    noun: 'Depósito',
    path: 'depositar',
    syncType: 'DEPOSITO',
    successTitle: 'Depósito realizado',
    pendingTitle: 'Depósito guardado',
    loadingLabel: 'Depositando',
    accountLabel: 'Conta de destino',
  ),
  withdraw(
    title: 'Sacar',
    noun: 'Saque',
    path: 'sacar',
    syncType: 'SAQUE',
    successTitle: 'Saque realizado',
    pendingTitle: 'Saque guardado',
    loadingLabel: 'Sacando',
    accountLabel: 'Conta de origem',
  );

  const OperationType({
    required this.title,
    required this.noun,
    required this.path,
    required this.syncType,
    required this.successTitle,
    required this.pendingTitle,
    required this.loadingLabel,
    required this.accountLabel,
  });

  final String title;
  final String noun;
  final String path;
  final String syncType;
  final String successTitle;
  final String pendingTitle;
  final String loadingLabel;
  final String accountLabel;

  double apply(double balance, double amount) {
    return this == deposit ? balance + amount : balance - amount;
  }

  static OperationType? fromSyncType(String value) {
    for (final type in values) {
      if (type.syncType == value) return type;
    }
    return null;
  }
}
