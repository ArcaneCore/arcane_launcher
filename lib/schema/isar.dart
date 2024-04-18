import 'dart:io';

import 'package:arcane_launcher/schema/external_application.dart';
import 'package:arcane_launcher/schema/server.dart';
import 'package:arcane_launcher/schema/setting.dart';
import 'package:isar/isar.dart';

late Isar isar;

class IsarInitializer {
  static Future<void> ensureInitialized() async {
    final directory = Directory.current;
    isar = await Isar.open(
      [ExternalApplicationSchema, ServerSchema, SettingSchema],
      directory: directory.path,
    );
  }
}
