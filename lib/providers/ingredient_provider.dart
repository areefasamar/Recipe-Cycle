import 'package:flutter/foundation.dart';
import '../models/ingredient.dart';
import '../services/local_data_service.dart';

/// Loads and filters the full ingredient list.
/// Exposes ingredients grouped by category, filtered by the current search text.
class IngredientProvider extends ChangeNotifier {
  final LocalDataService _service;

  IngredientProvider(this._service);

  List<Ingredient> _all = [];
  String _search = '';
  bool isLoading = false;
  String? error;

  String get search => _search;

  /// Called once at startup to populate the ingredient list.
  Future<void> loadIngredients() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _all = await _service.fetchIngredients();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String text) {
    _search = text.toLowerCase().trim();
    notifyListeners();
  }

  /// Returns the list filtered by search text (matches name or any alias).
  List<Ingredient> get filtered {
    if (_search.isEmpty) return _all;
    return _all.where((i) {
      final nameMatch = i.name.toLowerCase().contains(_search);
      // Also search aliases so typing "pyaz" finds "Onion"
      final aliasMatch = i.aliases.any((a) => a.toLowerCase().contains(_search));
      return nameMatch || aliasMatch;
    }).toList();
  }

  /// Returns the fixed category order; only includes categories that have
  /// at least one ingredient after filtering.
  static const List<String> categoryOrder = [
    'Vegetables',
    'Fruits',
    'Dairy and Eggs',
    'Meat and Fish',
    'Grains and Flour',
    'Lentils and Beans',
    'Spices',
    'Oils and Condiments',
    'Other',
  ];

  /// Groups the filtered list by category, preserving the fixed order.
  Map<String, List<Ingredient>> get groupedByCategory {
    final result = <String, List<Ingredient>>{};
    for (final category in categoryOrder) {
      final items = filtered.where((i) => i.category == category).toList();
      if (items.isNotEmpty) {
        result[category] = items;
      }
    }
    return result;
  }
}
