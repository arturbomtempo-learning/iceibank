import 'package:iceibank/domain/models/operation_type.dart';

enum PendingStatus {
  waiting('aguardando'),
  conflict('conflito'),
  rejected('recusada');

  const PendingStatus(this.storageValue);

  final String storageValue;

  static PendingStatus fromStorage(String value) {
    return values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => PendingStatus.waiting,
    );
  }
}

class PendingOperation {
  const PendingOperation({
    this.id,
    required this.username,
    required this.accountId,
    required this.agencyId,
    required this.type,
    required this.amountInCents,
    required this.knownVector,
    required this.createdAt,
    this.status = PendingStatus.waiting,
    this.message,
    this.serverBalance,
    this.serverVector,
  });

  final int? id;
  final String username;
  final int accountId;
  final int agencyId;
  final OperationType type;
  final int amountInCents;
  final List<int> knownVector;
  final DateTime createdAt;
  final PendingStatus status;
  final String? message;
  final double? serverBalance;
  final List<int>? serverVector;

  double get amount => amountInCents / 100;

  double get balanceEffect => type == OperationType.deposit ? amount : -amount;

  bool get isWaiting => status == PendingStatus.waiting;

  bool get needsDecision => status != PendingStatus.waiting;

  PendingOperation copyWith({
    int? id,
    List<int>? knownVector,
    PendingStatus? status,
    String? message,
    double? serverBalance,
    List<int>? serverVector,
    bool clearResolution = false,
  }) {
    return PendingOperation(
      id: id ?? this.id,
      username: username,
      accountId: accountId,
      agencyId: agencyId,
      type: type,
      amountInCents: amountInCents,
      knownVector: knownVector ?? this.knownVector,
      createdAt: createdAt,
      status: status ?? this.status,
      message: clearResolution ? null : message ?? this.message,
      serverBalance: clearResolution ? null : serverBalance ?? this.serverBalance,
      serverVector: clearResolution ? null : serverVector ?? this.serverVector,
    );
  }
}
