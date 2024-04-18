import 'package:isar/isar.dart';

part 'external_application.g.dart';

@collection
@Name('external_applications')
class ExternalApplication {
  Id id = Isar.autoIncrement;
  String name = '';
  String path = '';
  String description = '';
}
