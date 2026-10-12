import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_match.dart';
import '../providers/pantry_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeMatch match;

  const RecipeDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final recipe = match.recipe;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Description ─────────────────────────────────────────────
          if (recipe.description.isNotEmpty) ...[
            Text(recipe.description,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
          ],

          // ── Meta row ────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16),
              const SizedBox(width: 4),
              Text('${recipe.prepMinutes} min'),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline, size: 16),
              const SizedBox(width: 4),
              Text('${recipe.servings} servings'),
            ],
          ),
          const Divider(height: 32),

          // ── You have ────────────────────────────────────────────────
          Text('You have',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.green.shade700)),
          const SizedBox(height: 6),
          ...match.matched.map((slug) => _IngredientRow(slug: slug, have: true)),

          // ── You need ────────────────────────────────────────────────
          if (match.missing.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('You need',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 6),
            ...match.missing.map((slug) => _IngredientRow(slug: slug, have: false)),
          ],

          const Divider(height: 32),

          // ── Steps ───────────────────────────────────────────────────
          Text('Steps', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...recipe.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number in a small circle
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text('${entry.key + 1}',
                        style: const TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(entry.value,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── I cooked this ───────────────────────────────────────────
          FilledButton.icon(
            onPressed: () => _onCooked(context),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('I cooked this!'),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _onCooked(BuildContext context) async {
    // Remove only the ingredients the user actually had; don't touch missing ones
    await context.read<PantryProvider>().removeAll(match.matched);
    if (context.mounted) {
      // Pop back to checklist (two screens back: detail → results → checklist)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

/// One row in the ingredient list with a coloured leading icon.
class _IngredientRow extends StatelessWidget {
  final String slug;
  final bool have;

  const _IngredientRow({required this.slug, required this.have});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            have ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: have ? Colors.green.shade600 : Colors.grey,
          ),
          const SizedBox(width: 8),
          // Display slug with hyphens replaced by spaces for readability
          Text(slug.replaceAll('-', ' '),
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
