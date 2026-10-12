import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's pantry (a list of ingredient slugs) on the device.
class PantryStorage {
  static const _key = 'pantry_slugs';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Returns empty list if nothing has been saved yet
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> save(List<String> slugs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, slugs);
  }
}
