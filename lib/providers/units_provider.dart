import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/unit.dart';
import 'recipe_provider.dart';

final unitsProvider = FutureProvider.autoDispose<List<RecipeUnit>>((ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  return await repo.getUnits();
});
