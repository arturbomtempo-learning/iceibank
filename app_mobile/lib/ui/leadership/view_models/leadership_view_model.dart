import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/utils/result.dart';

class LeaderChange {
  const LeaderChange({
    required this.previousLeaderId,
    required this.newLeaderId,
    required this.detectedAt,
  });

  final int previousLeaderId;
  final int newLeaderId;
  final DateTime detectedAt;
}

class LeadershipViewModel extends ChangeNotifier {
  LeadershipViewModel({
    required this._leadershipRepository,
    this.interval = const Duration(seconds: 3),
  });

  final LeadershipRepository _leadershipRepository;
  final Duration interval;

  LeaderStatus? _status;
  LeaderChange? _lastChange;
  String? _errorMessage;
  int? _lastKnownLeaderId;
  Timer? _timer;
  bool _isRunning = false;
  bool _isChecking = false;
  bool _isDisposed = false;

  LeaderStatus? get status => _status;
  LeaderChange? get lastChange => _lastChange;
  String? get errorMessage => _errorMessage;
  int? get lastKnownLeaderId => _lastKnownLeaderId;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    unawaited(_poll());
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    if (_isChecking) return;

    _timer?.cancel();
    _isChecking = true;

    final result = await _leadershipRepository.fetchLeader(
      preferredAgencyId: _status?.sourceAgencyId,
    );

    _isChecking = false;
    if (_isDisposed) return;

    switch (result) {
      case Ok(:final value):
        _apply(value);
      case Failure(:final error):
        _errorMessage = error is ApiException
            ? error.message
            : const ApiException.unexpected().message;
    }
    notifyListeners();

    if (_isRunning) _timer = Timer(interval, () => unawaited(_poll()));
  }

  void _apply(LeaderStatus status) {
    _errorMessage = null;
    _status = status;

    final leaderId = status.leaderId;
    if (leaderId == null) return;

    final previous = _lastKnownLeaderId;
    if (previous != null && previous != leaderId) {
      _lastChange = LeaderChange(
        previousLeaderId: previous,
        newLeaderId: leaderId,
        detectedAt: status.checkedAt,
      );
    }
    _lastKnownLeaderId = leaderId;
  }

  @override
  void dispose() {
    _isDisposed = true;
    stop();
    super.dispose();
  }
}
