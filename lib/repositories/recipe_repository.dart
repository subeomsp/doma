import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe.dart';
import '../models/tag.dart';
import '../models/unit.dart';

class RecipeRepository {
  late Future<Isar> _db;

  RecipeRepository() {
    _db = _initDb();
  }

  Future<Isar> _initDb() async {
    Isar isar;
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        [RecipeSchema, RecipeTagSchema, RecipeUnitSchema],
        directory: dir.path,
      );
    } else {
      isar = Isar.getInstance()!;
    }
    
    // Auto-sync legacy tags into the new Tag collection
    final existingTagsCount = await isar.recipeTags.count();
    if (existingTagsCount == 0) {
      final recipes = await isar.recipes.where().findAll();
      final uniqueTags = <String>{};
      for (var r in recipes) {
        uniqueTags.addAll(r.tags);
      }
      if (uniqueTags.isNotEmpty) {
        await isar.writeTxn(() async {
          for (var t in uniqueTags) {
            await isar.recipeTags.put(RecipeTag()..name = t);
          }
        });
      }
    }
    
    // Auto-sync default units into the new Unit collection
    final existingUnitsCount = await isar.recipeUnits.count();
    if (existingUnitsCount == 0) {
      await isar.writeTxn(() async {
        for (var u in ['T', 't', 'L', 'ml', 'kg', 'g', 'cup', 'pinch']) {
          await isar.recipeUnits.put(RecipeUnit()..name = u);
        }
      });
    }

    return isar;
  }

  Future<List<RecipeTag>> getTags() async {
    final isar = await _db;
    return await isar.recipeTags.where().findAll();
  }

  Future<void> addTag(String name) async {
    final isar = await _db;
    final exists = await isar.recipeTags.filter().nameEqualTo(name).findFirst();
    if (exists == null) {
      await isar.writeTxn(() async {
        final tag = RecipeTag()..name = name;
        await isar.recipeTags.put(tag);
      });
    }
  }

  Future<void> deleteTag(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.recipeTags.delete(id);
    });
  }

  Future<List<RecipeUnit>> getUnits() async {
    final isar = await _db;
    return await isar.recipeUnits.where().findAll();
  }

  Future<void> addUnit(String name) async {
    final isar = await _db;
    final exists = await isar.recipeUnits.filter().nameEqualTo(name).findFirst();
    if (exists == null) {
      await isar.writeTxn(() async {
        final unit = RecipeUnit()..name = name;
        await isar.recipeUnits.put(unit);
      });
    }
  }

  Future<void> deleteUnit(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.recipeUnits.delete(id);
    });
  }

  Future<List<Recipe>> getAllRecipes() async {
    final isar = await _db;
    final recipes = await isar.recipes.where().findAll();
    recipes.sort((a, b) => (b.updatedAt ?? DateTime(1970)).compareTo(a.updatedAt ?? DateTime(1970)));
    return recipes;
  }
  
  Future<Recipe?> getRecipe(int id) async {
    final isar = await _db;
    return await isar.recipes.get(id);
  }

  Future<int> saveRecipe(Recipe recipe) async {
    final isar = await _db;
    recipe.updatedAt = DateTime.now();
    recipe.createdAt ??= DateTime.now();
    return await isar.writeTxn(() async {
      return await isar.recipes.put(recipe);
    });
  }

  Future<bool> deleteRecipe(int id) async {
    final isar = await _db;
    return await isar.writeTxn(() async {
      return await isar.recipes.delete(id);
    });
  }

  Future<List<Recipe>> searchRecipes(String query, List<String> tags) async {
    final isar = await _db;
    List<Recipe> recipes;

    if (query.isNotEmpty) {
      recipes = await isar.recipes.where().filter().titleContains(query, caseSensitive: false).findAll();
    } else {
      recipes = await isar.recipes.where().findAll();
    }

    recipes.sort((a, b) => (b.updatedAt ?? DateTime(1970)).compareTo(a.updatedAt ?? DateTime(1970)));
    
    if (tags.isEmpty) {
      return recipes;
    } else {
      return recipes.where((recipe) {
        // AND 조건: 선택한 태그를 모두 포함해야 함 (또는 OR 조건으로 변경 가능)
        // PRD에 "태그로 필터링하거나" 정도로 명시되어 있으므로 직관적인 교집합(AND) 사용
        return tags.every((tag) => recipe.tags.contains(tag));
      }).toList();
    }
  }
}
