import 'package:flutter/foundation.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgencyRepository extends ChangeNotifier {
  AgencyRepository({this._preferences});

  static const String _storageKey = 'iceibank.agency';
  static const String _automaticValue = 'auto';

  final SharedPreferencesAsync? _preferences;

  int? _pinnedAgencyId;

  int? get pinnedAgencyId => _pinnedAgencyId;

  bool get isAutomatic => _pinnedAgencyId == null;

  SharedPreferencesAsync get _storage => _preferences ?? SharedPreferencesAsync();

  Future<void> restore() async {
    final storedValue = await _storage.getString(_storageKey);
    final storedId = int.tryParse(storedValue ?? '');
    _pinnedAgencyId = storedId != null && AgencyEndpoints.ids.contains(storedId) ? storedId : null;
    notifyListeners();
  }

  Future<void> select(int? agencyId) async {
    if (agencyId != null && !AgencyEndpoints.ids.contains(agencyId)) return;
    if (agencyId == _pinnedAgencyId) return;

    _pinnedAgencyId = agencyId;
    notifyListeners();
    await _storage.setString(_storageKey, agencyId?.toString() ?? _automaticValue);
  }
}
