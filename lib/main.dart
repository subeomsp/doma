import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/recipe_detail_screen.dart';
import 'ui/screens/recipe_edit_screen.dart';

import 'ui/screens/tag_management_screen.dart';
import 'ui/screens/unit_management_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return RecipeDetailScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final idStr = state.uri.queryParameters['id'];
        final id = idStr != null ? int.parse(idStr) : null;
        return RecipeEditScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: '/tags',
      builder: (context, state) => const TagManagementScreen(),
    ),
    GoRoute(
      path: '/units',
      builder: (context, state) => const UnitManagementScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DOMA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
        ),
        fontFamily: 'GowunDodum',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Hahmlet', color: Colors.black, fontWeight: FontWeight.w600),
          displayMedium: TextStyle(fontFamily: 'Hahmlet', color: Colors.black, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(fontFamily: 'Hahmlet', color: Colors.black, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontFamily: 'Hahmlet', color: Colors.black, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontFamily: 'Hahmlet', color: Colors.black, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontFamily: 'Hahmlet', color: Colors.black, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          scrolledUnderElevation: 0,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(fontFamily: 'Hahmlet', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
