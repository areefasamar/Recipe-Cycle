import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ingredient_provider.dart';
import 'providers/pantry_provider.dart';
import 'providers/recipe_provider.dart';
import 'services/local_data_service.dart';
import 'services/pantry_storage.dart';
import 'screens/ingredient_checklist_screen.dart';

void main() {
  runApp(const RecipeCycleApp());
}

class RecipeCycleApp extends StatelessWidget {
  const RecipeCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider makes both providers available to the entire widget tree
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => IngredientProvider(LocalDataService()),
        ),
        ChangeNotifierProvider(
          create: (_) => PantryProvider(PantryStorage()),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(LocalDataService()),
        ),
      ],
      child: MaterialApp(
        title: 'Recipe Cycle',
        // Material 3 with a single seed color; light theme only
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const IngredientChecklistScreen(),
      ),
    );
  }
}
