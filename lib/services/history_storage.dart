import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

/// Persists the list of cooked recipes using SharedPreferences.
/// Retains only the 50 most recent entries.
class HistoryStorage {
  static const _key = 'cooked_history';

  Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList
        .map((str) {
          try {
            return HistoryEntry.fromJson(
              json.decode(str) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<HistoryEntry>()
        .toList();
  }

  Future<void> save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep the newest 50 entries only
    final capped = entries.take(50).toList();
    final stringList = capped.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_key, stringList);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
