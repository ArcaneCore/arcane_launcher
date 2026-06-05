import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/database/database.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:signals/signals.dart';

class ExternalApplicationViewModel {
  final _apps = signal<List<ExternalApplication>>([]);

  List<ExternalApplication> get applications => _apps.value;

  Future<void> fetch() async {
    final results = await laconic.table('external_applications').get();
    _apps.value =
        results.map((r) => ExternalApplication.fromMap(r.toMap())).toList();
  }

  void start(int index) {
    final apps = _apps.value;
    if (index >= apps.length) return;
    ProcessUtil().start(apps[index].path);
  }

  Future<void> store(ExternalApplication application) async {
    if (application.id != null && application.id != 0) {
      await laconic
          .table('external_applications')
          .where('id', application.id!)
          .update(application.toMap());
    } else {
      final id = await laconic
          .table('external_applications')
          .insertGetId(application.toMap());
      application.id = id;
    }
    await fetch();
  }

  Future<void> destroy(ExternalApplication application) async {
    await laconic
        .table('external_applications')
        .where('id', application.id!)
        .delete();
    await fetch();
  }
}
