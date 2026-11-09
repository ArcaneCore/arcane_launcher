import 'package:arcane_launcher/model/config_document.dart';
import 'package:arcane_launcher/schema/server.dart';

/// Shared contract for view models that edit a server config file.
abstract interface class ConfigViewModel {
  /// Parsed file, or null when the server has no config path configured.
  ConfigDocument? get document;

  /// Loads (or reloads) the config file of [server].
  Future<void> fetchConfig(ServerEntity server);

  /// Serializes [document] back to the configured file.
  Future<void> storeConfig(ServerEntity server);
}
