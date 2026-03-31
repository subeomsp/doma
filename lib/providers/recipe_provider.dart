import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final tagFilterProvider = StateProvider<List<String>>((ref) => []);

final recipeListProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  final tags = ref.watch(tagFilterProvider);
  
  return await repo.searchRecipes(query, tags);
});

// A provider to fetch a single recipe
final recipeDetailProvider = FutureProvider.autoDispose.family<Recipe?, int>((ref, id) async {
  final repo = ref.watch(recipeRepositoryProvider);
  return await repo.getRecipe(id);
});
