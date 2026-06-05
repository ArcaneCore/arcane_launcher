import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/schema/laconic.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'external_application.g.dart';

@riverpod
class ExternalApplicationsNotifier extends _$ExternalApplicationsNotifier {
  @override
  Future<List<ExternalApplication>> build() async {
    final results = await laconic.table('external_applications').get();
    return results.map((r) => ExternalApplication.fromMap(r.toMap())).toList();
  }

  void start(int index) async {
    final applications = await future;
    if (index >= applications.length) return;
    ProcessUtil().start(applications[index].path);
  }

  Future<void> store(ExternalApplication application) async {
    if (application.id != null && application.id != 0) {
      await laconic.table('external_applications').where('id', application.id!).update(application.toMap());
    } else {
      final id = await laconic.table('external_applications').insertGetId(application.toMap());
      application.id = id;
    }
    ref.invalidateSelf();
  }

  Future<void> destroy(ExternalApplication application) async {
    await laconic.table('external_applications').where('id', application.id!).delete();
    ref.invalidateSelf();
  }
}
