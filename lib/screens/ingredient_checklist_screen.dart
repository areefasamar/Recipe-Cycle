import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import 'recipe_results_screen.dart';

// Emoji for each category, in the fixed order from the architecture doc
const Map<String, String> _categoryEmoji = {
  'Vegetables':        '🥦',
  'Fruits':            '🍎',
  'Dairy and Eggs':    '🥛',
  'Meat and Fish':     '🍗',
  'Grains and Flour':  '🌾',
  'Lentils and Beans': '🫘',
  'Spices':            '🌶️',
  'Oils and Condiments':'🫙',
  'Other':             '🍽️',
};

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
      final ingredientProvider = context.read<IngredientProvider>();
      final pantryProvider     = context.read<PantryProvider>();
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
    final ip     = context.watch<IngredientProvider>();
    final pantry = context.watch<PantryProvider>();

    return Scaffold(
      // No appBar — we use a custom SliverAppBar header inside the scroll view
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Branded header ──────────────────────────────────
                SliverToBoxAdapter(child: _Header()),

                // ── Search bar ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppTheme.spaceM, 0, AppTheme.spaceM, AppTheme.spaceM),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search by name or alias…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ip.setSearch('');
                                },
                              )
                            : null,
                      ),
                      onChanged: ip.setSearch,
                    ),
                  ),
                ),

                // ── Ingredient list or state views ───────────────────
                _buildSliverBody(context, ip, pantry),
              ],
            ),
          ),

          // ── Animated bottom bar ─────────────────────────────────────
          _BottomBar(pantry: pantry, onFindRecipes: _onFindRecipes),
        ],
      ),
    );
  }

  Widget _buildSliverBody(
      BuildContext context, IngredientProvider ip, PantryProvider pantry) {
    if (ip.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ip.error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: AppTheme.spaceS),
              Text(ip.error!),
              const SizedBox(height: AppTheme.spaceM),
              ElevatedButton.icon(
                onPressed: ip.loadIngredients,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = ip.groupedByCategory;

    if (grouped.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppTheme.spaceM),
              Text(
                'Nothing found for "${ip.search}"',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceS),
              const Text(
                'Try the English name or a common alias.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // One sliver list item per category section
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = grouped.entries.elementAt(index);
          return _CategorySection(
            category:    entry.key,
            ingredients: entry.value,
            pantry:      pantry,
          );
        },
        childCount: grouped.length,
      ),
    );
  }

  Future<void> _onFindRecipes() async {
    final pantry         = context.read<PantryProvider>();
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

// ── Branded header ─────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Slight gradient so the header feels distinct without a hard line
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withOpacity(0.08),
            AppTheme.background,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceM,
        MediaQuery.of(context).padding.top + AppTheme.spaceM,
        AppTheme.spaceM,
        AppTheme.spaceL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row: leaf icon + app name
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.eco_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppTheme.spaceS),
              Text(
                'Recipe Cycle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceM),

          // Sub-heading
          Text(
            "What's in your\nkitchen today?",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF1A1A1A),
                  height: 1.15,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Category section ───────────────────────────────────────────────────────

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
    final emoji       = _categoryEmoji[category] ?? '🍽️';
    final tickedCount = ingredients.where((i) => pantry.has(i.slug)).length;

    return ExpansionTile(
      initiallyExpanded: true,
      // Emoji + category name as the tile title
      title: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppTheme.spaceS),
          Text(
            category,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: const Color(0xFF1A1A1A)),
          ),
          if (tickedCount > 0) ...[
            const SizedBox(width: AppTheme.spaceS),
            // Small pill showing how many ticked in this category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$tickedCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
      children: [
        // Ingredient chips in a Wrap
        Wrap(
          spacing: AppTheme.spaceS,
          runSpacing: AppTheme.spaceS,
          children: ingredients.map((ing) {
            return _IngredientChip(ingredient: ing, pantry: pantry);
          }).toList(),
        ),
        const SizedBox(height: AppTheme.spaceS),
      ],
    );
  }
}

// ── Ingredient chip ────────────────────────────────────────────────────────

class _IngredientChip extends StatelessWidget {
  final Ingredient ingredient;
  final PantryProvider pantry;

  const _IngredientChip({required this.ingredient, required this.pantry});

  @override
  Widget build(BuildContext context) {
    final selected = pantry.has(ingredient.slug);

    return GestureDetector(
      onTap: () => pantry.toggle(ingredient.slug),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // Fill green when selected, soft cream when not
          color: selected ? AppTheme.primary : const Color(0xFFEDE8DF),
          borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated check icon that fades in/out with selection
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: selected
                  ? const Padding(
                      key: ValueKey('check'),
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            Text(
              ingredient.name,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF3D3D3D),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated bottom bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final PantryProvider pantry;
  final VoidCallback onFindRecipes;

  const _BottomBar({required this.pantry, required this.onFindRecipes});

  @override
  Widget build(BuildContext context) {
    final count = pantry.count;

    // Slides up from below when something is selected; hides when nothing is
    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      offset: count > 0 ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: count > 0 ? 1.0 : 0.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppTheme.spaceM,
            AppTheme.spaceM,
            AppTheme.spaceM,
            MediaQuery.of(context).padding.bottom + AppTheme.spaceM,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Selected count label
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count ingredient${count == 1 ? '' : 's'} selected',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    // Clear button sits below the count
                    GestureDetector(
                      onTap: pantry.clear,
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spaceM),
              // Find recipes button
              FilledButton.icon(
                onPressed: count > 0 ? onFindRecipes : null,
                icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                label: const Text('Find Recipes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
