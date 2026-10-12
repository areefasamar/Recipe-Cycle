import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'recipe_detail_screen.dart';

class RecipeResultsScreen extends StatelessWidget {
  const RecipeResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recipes for you')),
      body: _buildBody(context, recipeProvider),
    );
  }

  Widget _buildBody(BuildContext context, RecipeProvider rp) {
    if (rp.isLoading) return const LoadingView();

    if (rp.error != null) {
      return ErrorView(
        message: rp.error!,
        // Re-read the pantry from context to retry the same query
        onRetry: () {
          // The results screen itself doesn't hold pantry slugs; the caller
          // already triggered match() before pushing this route. On retry we
          // just call match() again with whatever is currently in the provider.
          // Because we don't have the slugs here, we simply pop and let the
          // user tap "Find Recipes" again — simplest option per section 12.
          Navigator.of(context).pop();
        },
      );
    }

    if (rp.results.isEmpty) {
      return const EmptyView(
        message: 'No recipes match your pantry yet.\nTry ticking more ingredients.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rp.results.length,
      itemBuilder: (context, index) {
        final match = rp.results[index];
        return RecipeCard(
          match: match,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(match: match),
            ),
          ),
        );
      },
    );
  }
}
