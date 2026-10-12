import 'package:flutter/foundation.dart';
import '../services/pantry_storage.dart';

/// Holds the set of slugs the user has ticked.
/// Persists to shared_preferences on every change.
class PantryProvider extends ChangeNotifier {
  final PantryStorage _storage;

  PantryProvider(this._storage);

  Set<String> _slugs = {};

  Set<String> get slugs => _slugs;

  int get count => _slugs.length;

  bool has(String slug) => _slugs.contains(slug);

  /// Load the saved pantry at app startup.
  Future<void> load() async {
    final saved = await _storage.load();
    _slugs = saved.toSet();
    notifyListeners();
  }

  /// Add or remove a slug and immediately persist the new state.
  Future<void> toggle(String slug) async {
    if (_slugs.contains(slug)) {
      _slugs.remove(slug);
    } else {
      _slugs.add(slug);
    }
    notifyListeners();
    await _storage.save(_slugs.toList());
  }

  Future<void> clear() async {
    _slugs.clear();
    notifyListeners();
    await _storage.save([]);
  }

  /// Remove a specific set of slugs (used by "I cooked this" in a later milestone).
  Future<void> removeAll(List<String> remove) async {
    _slugs.removeAll(remove);
    notifyListeners();
    await _storage.save(_slugs.toList());
  }
}
