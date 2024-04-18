// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_server.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServerInformationNotifierHash() =>
    r'3480790fa8a4e4562b397a5e2289860474a8a2da';

/// See also [AuthServerInformationNotifier].
@ProviderFor(AuthServerInformationNotifier)
final authServerInformationNotifierProvider = AutoDisposeAsyncNotifierProvider<
    AuthServerInformationNotifier, ServiceInformation>.internal(
  AuthServerInformationNotifier.new,
  name: r'authServerInformationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServerInformationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthServerInformationNotifier
    = AutoDisposeAsyncNotifier<ServiceInformation>;
String _$authServerConfigNotifierHash() =>
    r'1bb0ba571cc59d48f7d0e58bf8eab352664056c7';

/// See also [AuthServerConfigNotifier].
@ProviderFor(AuthServerConfigNotifier)
final authServerConfigNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthServerConfigNotifier, String>.internal(
  AuthServerConfigNotifier.new,
  name: r'authServerConfigNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServerConfigNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthServerConfigNotifier = AutoDisposeAsyncNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
