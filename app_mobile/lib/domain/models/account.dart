class Account {
  const Account({
    required this.id,
    required this.holderName,
    required this.owner,
    required this.balance,
    required this.agencyId,
  });

  final int id;
  final String holderName;
  final String owner;
  final double balance;
  final int agencyId;

  Account copyWith({double? balance}) {
    return Account(
      id: id,
      holderName: holderName,
      owner: owner,
      balance: balance ?? this.balance,
      agencyId: agencyId,
    );
  }

  static Account? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;

    if (json case {
      'id': final int id,
      'dono': final String owner,
      'saldo': final num balance,
      'agencia': final int agencyId,
    }) {
      final holderName = json['nomeAluno'];

      return Account(
        id: id,
        holderName: holderName is String && holderName.trim().isNotEmpty
            ? holderName.trim()
            : owner,
        owner: owner,
        balance: balance.toDouble(),
        agencyId: agencyId,
      );
    }
    return null;
  }
}
