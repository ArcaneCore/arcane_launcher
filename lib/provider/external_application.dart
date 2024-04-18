import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/schema/isar.dart';
import 'package:arcane_launcher/util/process.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'external_application.g.dart';

@riverpod
class ExternalApplicationsNotifier extends _$ExternalApplicationsNotifier {
  @override
  Future<List<ExternalApplication>> build() async {
    return await isar.externalApplications.where().findAll();
  }

  void start(int index) async {
    final applications = await future;
    if (index >= applications.length) return;
    ProcessUtil().start(applications[index].path);
  }

  Future<void> store(ExternalApplication application) async {
    await isar.writeTxn(() async {
      await isar.externalApplications.put(application);
    });
    ref.invalidateSelf();
  }

  Future<void> destroy(ExternalApplication application) async {
    await isar.writeTxn(() async {
      await isar.externalApplications.delete(application.id);
    });
    ref.invalidateSelf();
  }
}
