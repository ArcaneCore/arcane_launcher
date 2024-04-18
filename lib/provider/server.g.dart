// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serversNotifierHash() => r'bc11b33807ac53e1324d361e904895c2765828e3';

/// See also [ServersNotifier].
@ProviderFor(ServersNotifier)
final serversNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ServersNotifier, List<Server>>.internal(
  ServersNotifier.new,
  name: r'serversNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serversNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServersNotifier = AutoDisposeAsyncNotifier<List<Server>>;
String _$activeServerNotifierHash() =>
    r'318e71ac2cbd23b91dfd4d5d2aa9c1e6363b2e17';

/// See also [ActiveServerNotifier].
@ProviderFor(ActiveServerNotifier)
final activeServerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ActiveServerNotifier, Server>.internal(
  ActiveServerNotifier.new,
  name: r'activeServerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeServerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveServerNotifier = AutoDisposeAsyncNotifier<Server>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
