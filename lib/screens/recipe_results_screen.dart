import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/state_views.dart';
import 'recipe_detail_screen.dart';

class RecipeResultsScreen extends StatelessWidget {
  const RecipeResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipes for you',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(context, recipeProvider),
    );
  }

  Widget _buildBody(BuildContext context, RecipeProvider rp) {
    if (rp.isLoading) return const LoadingView();

    if (rp.error != null) {
      return ErrorView(
        message: rp.error!,
        onRetry: () => Navigator.of(context).pop(),
      );
    }

    if (rp.results.isEmpty) {
      return EmptyView(
        emoji: '🥣',
        message: 'No matches yet, try adding a few more ingredients',
        actionLabel: 'Back to Kitchen',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceS),
      itemCount: rp.results.length,
      itemBuilder: (context, index) {
        final match = rp.results[index];
        // Staggered fade and slide animation
        final delayMs = index * 80;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + delayMs),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: RecipeCard(
            match: match,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(match: match),
              ),
            ),
          ),
        );
      },
    );
  }
}
