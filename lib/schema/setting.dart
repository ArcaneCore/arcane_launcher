import 'package:isar/isar.dart';

part 'setting.g.dart';

@collection
@Name('settings')
class Setting {
  Id id = Isar.autoIncrement;
  int color = 4288423856;
  @Name('dark_mode')
  bool darkMode = false;
}
