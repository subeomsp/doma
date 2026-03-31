import 'package:isar/isar.dart';
import 'ingredient.dart';

part 'recipe.g.dart';

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  late String title;

  String? memo;

  String? youtubeUrl;

  List<String> tags = [];

  List<Ingredient> ingredients = [];

  String? coverPhotoPath;

  DateTime? createdAt;

  DateTime? updatedAt;
}
