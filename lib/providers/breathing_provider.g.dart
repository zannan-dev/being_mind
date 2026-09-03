// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$breathingSessionHash() => r'e90a4e2447b8c440bc03f39ed689d0e15b751e1e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BreathingSession
    extends BuildlessAutoDisposeNotifier<BreathingSessionState> {
  late final int defaultTargetCycles;
  late final Duration startDelay;

  BreathingSessionState build({
    required int defaultTargetCycles,
    required Duration startDelay,
  });
}

/// See also [BreathingSession].
@ProviderFor(BreathingSession)
const breathingSessionProvider = BreathingSessionFamily();

/// See also [BreathingSession].
class BreathingSessionFamily extends Family<BreathingSessionState> {
  /// See also [BreathingSession].
  const BreathingSessionFamily();

  /// See also [BreathingSession].
  BreathingSessionProvider call({
    required int defaultTargetCycles,
    required Duration startDelay,
  }) {
    return BreathingSessionProvider(
      defaultTargetCycles: defaultTargetCycles,
      startDelay: startDelay,
    );
  }

  @override
  BreathingSessionProvider getProviderOverride(
    covariant BreathingSessionProvider provider,
  ) {
    return call(
      defaultTargetCycles: provider.defaultTargetCycles,
      startDelay: provider.startDelay,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'breathingSessionProvider';
}

/// See also [BreathingSession].
class BreathingSessionProvider
    extends
        AutoDisposeNotifierProviderImpl<
          BreathingSession,
          BreathingSessionState
        > {
  /// See also [BreathingSession].
  BreathingSessionProvider({
    required int defaultTargetCycles,
    required Duration startDelay,
  }) : this._internal(
         () => BreathingSession()
           ..defaultTargetCycles = defaultTargetCycles
           ..startDelay = startDelay,
         from: breathingSessionProvider,
         name: r'breathingSessionProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$breathingSessionHash,
         dependencies: BreathingSessionFamily._dependencies,
         allTransitiveDependencies:
             BreathingSessionFamily._allTransitiveDependencies,
         defaultTargetCycles: defaultTargetCycles,
         startDelay: startDelay,
       );

  BreathingSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.defaultTargetCycles,
    required this.startDelay,
  }) : super.internal();

  final int defaultTargetCycles;
  final Duration startDelay;

  @override
  BreathingSessionState runNotifierBuild(covariant BreathingSession notifier) {
    return notifier.build(
      defaultTargetCycles: defaultTargetCycles,
      startDelay: startDelay,
    );
  }

  @override
  Override overrideWith(BreathingSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: BreathingSessionProvider._internal(
        () => create()
          ..defaultTargetCycles = defaultTargetCycles
          ..startDelay = startDelay,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        defaultTargetCycles: defaultTargetCycles,
        startDelay: startDelay,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<BreathingSession, BreathingSessionState>
  createElement() {
    return _BreathingSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BreathingSessionProvider &&
        other.defaultTargetCycles == defaultTargetCycles &&
        other.startDelay == startDelay;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, defaultTargetCycles.hashCode);
    hash = _SystemHash.combine(hash, startDelay.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BreathingSessionRef
    on AutoDisposeNotifierProviderRef<BreathingSessionState> {
  /// The parameter `defaultTargetCycles` of this provider.
  int get defaultTargetCycles;

  /// The parameter `startDelay` of this provider.
  Duration get startDelay;
}

class _BreathingSessionProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          BreathingSession,
          BreathingSessionState
        >
    with BreathingSessionRef {
  _BreathingSessionProviderElement(super.provider);

  @override
  int get defaultTargetCycles =>
      (origin as BreathingSessionProvider).defaultTargetCycles;
  @override
  Duration get startDelay => (origin as BreathingSessionProvider).startDelay;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
