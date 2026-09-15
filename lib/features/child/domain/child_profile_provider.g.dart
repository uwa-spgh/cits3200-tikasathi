// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$childProfileHash() => r'837af8b1037a35ff0ceaaf978513c338016a2a08';

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

/// See also [childProfile].
@ProviderFor(childProfile)
const childProfileProvider = ChildProfileFamily();

/// See also [childProfile].
class ChildProfileFamily extends Family<AsyncValue<ChildProfileDetails>> {
  /// See also [childProfile].
  const ChildProfileFamily();

  /// See also [childProfile].
  ChildProfileProvider call(
    String childId,
  ) {
    return ChildProfileProvider(
      childId,
    );
  }

  @override
  ChildProfileProvider getProviderOverride(
    covariant ChildProfileProvider provider,
  ) {
    return call(
      provider.childId,
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
  String? get name => r'childProfileProvider';
}

/// See also [childProfile].
class ChildProfileProvider
    extends AutoDisposeFutureProvider<ChildProfileDetails> {
  /// See also [childProfile].
  ChildProfileProvider(
    String childId,
  ) : this._internal(
          (ref) => childProfile(
            ref as ChildProfileRef,
            childId,
          ),
          from: childProfileProvider,
          name: r'childProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$childProfileHash,
          dependencies: ChildProfileFamily._dependencies,
          allTransitiveDependencies:
              ChildProfileFamily._allTransitiveDependencies,
          childId: childId,
        );

  ChildProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.childId,
  }) : super.internal();

  final String childId;

  @override
  Override overrideWith(
    FutureOr<ChildProfileDetails> Function(ChildProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChildProfileProvider._internal(
        (ref) => create(ref as ChildProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        childId: childId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChildProfileDetails> createElement() {
    return _ChildProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildProfileProvider && other.childId == childId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, childId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChildProfileRef on AutoDisposeFutureProviderRef<ChildProfileDetails> {
  /// The parameter `childId` of this provider.
  String get childId;
}

class _ChildProfileProviderElement
    extends AutoDisposeFutureProviderElement<ChildProfileDetails>
    with ChildProfileRef {
  _ChildProfileProviderElement(super.provider);

  @override
  String get childId => (origin as ChildProfileProvider).childId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
