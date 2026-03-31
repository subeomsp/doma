import 'package:isar/isar.dart';

part 'tag.g.dart';

@collection
class RecipeTag {
  Id id = Isar.autoIncrement;
  late String name;
}
