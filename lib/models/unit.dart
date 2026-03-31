import 'package:isar/isar.dart';

part 'unit.g.dart';

@collection
class RecipeUnit {
  Id id = Isar.autoIncrement;
  late String name;
}
