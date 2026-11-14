class Account {
  const Account({
    required this.id,
    required this.holderName,
    required this.owner,
    required this.balance,
    required this.agencyId,
    this.vector,
    this.cachedAt,
  });

  final int id;
  final String holderName;
  final String owner;
  final double balance;
  final int agencyId;
  final List<int>? vector;
  final DateTime? cachedAt;

  bool get isStale => cachedAt != null;

  Account copyWith({double? balance, List<int>? vector, bool fresh = false}) {
    return Account(
      id: id,
      holderName: holderName,
      owner: owner,
      balance: balance ?? this.balance,
      agencyId: agencyId,
      vector: vector ?? this.vector,
      cachedAt: fresh ? null : cachedAt,
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
        vector: parseVector(json['vetorAtual']),
      );
    }
    return null;
  }

  static List<int>? parseVector(Object? json) {
    if (json is! List<Object?> || json.isEmpty) return null;
    final positions = json.whereType<int>().toList();
    if (positions.length != json.length) return null;
    return List.unmodifiable(positions);
  }
}
