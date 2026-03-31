import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import 'recipe_provider.dart';

final tagsProvider = FutureProvider.autoDispose<List<RecipeTag>>((ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  return await repo.getTags();
});
