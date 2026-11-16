import 'package:flutter/foundation.dart';
import '../models/history_entry.dart';
import '../services/history_storage.dart';

/// Manages the list of recipes the user has cooked.
class HistoryProvider extends ChangeNotifier {
  final HistoryStorage _storage;
  List<HistoryEntry> _entries = [];
  bool _isLoading = false;

  HistoryProvider(this._storage) {
    load();
  }

  List<HistoryEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _storage.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(HistoryEntry entry) async {
    _entries.insert(0, entry);
    if (_entries.length > 50) {
      _entries = _entries.sublist(0, 50);
    }
    notifyListeners();
    await _storage.save(_entries);
  }

  Future<void> clear() async {
    _entries.clear();
    notifyListeners();
    await _storage.clear();
  }
}
