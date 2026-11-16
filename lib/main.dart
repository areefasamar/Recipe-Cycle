import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/ingredient_provider.dart';
import 'providers/pantry_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/ingredient_checklist_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/history_storage.dart';
import 'services/pantry_storage.dart';
import 'services/token_storage.dart';
import 'theme/app_theme.dart';
import 'widgets/state_views.dart';

void main() {
  runApp(const RecipeCycleApp());
}

class RecipeCycleApp extends StatelessWidget {
  const RecipeCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final authService = AuthService();
    final tokenStorage = TokenStorage();

    // MultiProvider makes all providers available to the entire widget tree
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, tokenStorage)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => IngredientProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => PantryProvider(PantryStorage()),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(HistoryStorage()),
        ),
      ],
      child: MaterialApp(
        title: 'Recipe Cycle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.checking) {
      return const Scaffold(body: LoadingView());
    }

    if (auth.status == AuthStatus.loggedIn || auth.isGuest) {
      return const IngredientChecklistScreen();
    }

    return const LoginScreen();
  }
}
