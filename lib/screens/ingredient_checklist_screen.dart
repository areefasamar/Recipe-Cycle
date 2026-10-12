import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import 'recipe_results_screen.dart';

class IngredientChecklistScreen extends StatefulWidget {
  const IngredientChecklistScreen({super.key});

  @override
  State<IngredientChecklistScreen> createState() =>
      _IngredientChecklistScreenState();
}

class _IngredientChecklistScreenState
    extends State<IngredientChecklistScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load ingredients after the first frame so the context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ingredientProvider =
          context.read<IngredientProvider>();
      final pantryProvider = context.read<PantryProvider>();
      await Future.wait([
        ingredientProvider.loadIngredients(),
        pantryProvider.load(),
      ]);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientProvider = context.watch<IngredientProvider>();
    final pantryProvider = context.watch<PantryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('What\'s in your kitchen?'),
        // Show how many ingredients are ticked in the app bar
        actions: [
          if (pantryProvider.count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('${pantryProvider.count} selected'),
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search (e.g. pyaz, chicken…)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                isDense: true,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ingredientProvider.setSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: ingredientProvider.setSearch,
            ),
          ),

          // ── Ingredient list ─────────────────────────────────────────
          Expanded(
            child: _buildBody(ingredientProvider, pantryProvider),
          ),
        ],
      ),

      // ── Find Recipes button ─────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            // Disabled until at least one ingredient is ticked
            onPressed: pantryProvider.count > 0 ? _onFindRecipes : null,
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Find Recipes'),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      IngredientProvider ip, PantryProvider pantry) {
    if (ip.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ip.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(ip.error!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ip.loadIngredients(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final grouped = ip.groupedByCategory;

    if (grouped.isEmpty) {
      return const Center(child: Text('No ingredients found.'));
    }

    return ListView(
      children: grouped.entries.map((entry) {
        return _CategorySection(
          category: entry.key,
          ingredients: entry.value,
          pantry: pantry,
        );
      }).toList(),
    );
  }

  Future<void> _onFindRecipes() async {
    final pantry = context.read<PantryProvider>();
    final recipeProvider = context.read<RecipeProvider>();

    // Kick off matching before pushing so the results screen sees the state
    await recipeProvider.match(pantry.slugs.toList());

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecipeResultsScreen()),
    );
  }
}

/// One collapsible category section using ExpansionTile.
class _CategorySection extends StatelessWidget {
  final String category;
  final List<Ingredient> ingredients;
  final PantryProvider pantry;

  const _CategorySection({
    required this.category,
    required this.ingredients,
    required this.pantry,
  });

  @override
  Widget build(BuildContext context) {
    // Count how many in this category are ticked to show in the tile subtitle
    final tickedCount =
        ingredients.where((i) => pantry.has(i.slug)).length;

    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(category,
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: tickedCount > 0
          ? Text('$tickedCount of ${ingredients.length} selected',
              style: Theme.of(context).textTheme.bodySmall)
          : null,
      children: ingredients.map((ing) {
        return CheckboxListTile(
          title: Text(ing.name),
          // Show aliases as subtle hint so users can confirm the desi name
          subtitle: ing.aliases.isNotEmpty
              ? Text(ing.aliases.join(', '),
                  style: Theme.of(context).textTheme.bodySmall)
              : null,
          value: pantry.has(ing.slug),
          onChanged: (_) => pantry.toggle(ing.slug),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}
