import 'dart:convert';

import 'package:iceibank/data/services/offline_store.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteOfflineStore implements OfflineStore {
  SqliteOfflineStore({this.fileName = 'iceibank.db'});

  static const int _schemaVersion = 1;

  final String fileName;

  Future<Database>? _database;

  Future<Database> get _db => _database ??= _open();

  Future<Database> _open() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      p.join(directory, fileName),
      version: _schemaVersion,
      onCreate: (db, _) async {
        final batch = db.batch()
          ..execute('''
            CREATE TABLE cached_accounts (
              username TEXT NOT NULL,
              account_id INTEGER NOT NULL,
              holder_name TEXT NOT NULL,
              owner TEXT NOT NULL,
              balance REAL NOT NULL,
              agency_id INTEGER NOT NULL,
              vector TEXT,
              synced_at INTEGER NOT NULL,
              PRIMARY KEY (username, account_id)
            )
          ''')
          ..execute('''
            CREATE TABLE pending_operations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              account_id INTEGER NOT NULL,
              agency_id INTEGER NOT NULL,
              type TEXT NOT NULL,
              amount_cents INTEGER NOT NULL,
              known_vector TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              status TEXT NOT NULL,
              message TEXT,
              server_balance REAL,
              server_vector TEXT
            )
          ''')
          ..execute('CREATE INDEX pending_operations_by_user ON pending_operations (username, id)');
        await batch.commit(noResult: true);
      },
    );
  }

  @override
  Future<List<Account>> readAccounts(String username) async {
    final db = await _db;
    final rows = await db.query(
      'cached_accounts',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'account_id',
    );
    return rows.map(_accountFromRow).toList();
  }

  @override
  Future<void> replaceAccounts(
    String username,
    List<Account> accounts, {
    required Iterable<int> refreshedAgencies,
  }) async {
    final db = await _db;
    final agencies = refreshedAgencies.toList();
    final syncedAt = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      if (agencies.isNotEmpty) {
        await txn.delete(
          'cached_accounts',
          where: 'username = ? AND agency_id IN (${List.filled(agencies.length, '?').join(', ')})',
          whereArgs: [username, ...agencies],
        );
      }

      final batch = txn.batch();
      for (final account in accounts) {
        batch.insert(
          'cached_accounts',
          _accountToRow(username, account, syncedAt),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> saveAccount(String username, Account account) async {
    final db = await _db;
    await db.insert(
      'cached_accounts',
      _accountToRow(username, account, DateTime.now().millisecondsSinceEpoch),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clearAccounts(String username) async {
    final db = await _db;
    await db.delete('cached_accounts', where: 'username = ?', whereArgs: [username]);
  }

  @override
  Future<List<PendingOperation>> readOperations(String username) async {
    final db = await _db;
    final rows = await db.query(
      'pending_operations',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id',
    );
    return rows.map(_operationFromRow).nonNulls.toList();
  }

  @override
  Future<PendingOperation> insertOperation(PendingOperation operation) async {
    final db = await _db;
    final id = await db.insert('pending_operations', _operationToRow(operation));
    return operation.copyWith(id: id);
  }

  @override
  Future<void> updateOperation(PendingOperation operation) async {
    final id = operation.id;
    if (id == null) return;

    final db = await _db;
    await db.update(
      'pending_operations',
      _operationToRow(operation),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteOperation(int id) async {
    final db = await _db;
    await db.delete('pending_operations', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _accountToRow(String username, Account account, int syncedAt) {
    return {
      'username': username,
      'account_id': account.id,
      'holder_name': account.holderName,
      'owner': account.owner,
      'balance': account.balance,
      'agency_id': account.agencyId,
      'vector': _encodeVector(account.vector),
      'synced_at': syncedAt,
    };
  }

  Account _accountFromRow(Map<String, Object?> row) {
    return Account(
      id: row['account_id']! as int,
      holderName: row['holder_name']! as String,
      owner: row['owner']! as String,
      balance: (row['balance']! as num).toDouble(),
      agencyId: row['agency_id']! as int,
      vector: _decodeVector(row['vector']),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(row['synced_at']! as int),
    );
  }

  Map<String, Object?> _operationToRow(PendingOperation operation) {
    return {
      'username': operation.username,
      'account_id': operation.accountId,
      'agency_id': operation.agencyId,
      'type': operation.type.syncType,
      'amount_cents': operation.amountInCents,
      'known_vector': _encodeVector(operation.knownVector),
      'created_at': operation.createdAt.millisecondsSinceEpoch,
      'status': operation.status.storageValue,
      'message': operation.message,
      'server_balance': operation.serverBalance,
      'server_vector': _encodeVector(operation.serverVector),
    };
  }

  PendingOperation? _operationFromRow(Map<String, Object?> row) {
    final type = OperationType.fromSyncType(row['type']! as String);
    final knownVector = _decodeVector(row['known_vector']);
    if (type == null || knownVector == null) return null;

    return PendingOperation(
      id: row['id']! as int,
      username: row['username']! as String,
      accountId: row['account_id']! as int,
      agencyId: row['agency_id']! as int,
      type: type,
      amountInCents: row['amount_cents']! as int,
      knownVector: knownVector,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
      status: PendingStatus.fromStorage(row['status']! as String),
      message: row['message'] as String?,
      serverBalance: (row['server_balance'] as num?)?.toDouble(),
      serverVector: _decodeVector(row['server_vector']),
    );
  }

  String? _encodeVector(List<int>? vector) => vector == null ? null : jsonEncode(vector);

  List<int>? _decodeVector(Object? value) {
    if (value is! String) return null;
    try {
      return Account.parseVector(jsonDecode(value));
    } on FormatException {
      return null;
    }
  }
}
