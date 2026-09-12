// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_dose_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordDoseControllerHash() =>
    r'78d2312bf788680dcbfd3113b981bd06e21164da';

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

abstract class _$RecordDoseController
    extends BuildlessAutoDisposeAsyncNotifier<RecordDoseState> {
  late final String childId;

  FutureOr<RecordDoseState> build(
    String childId,
  );
}

/// Drives the screen where a caregiver logs doses a child has just been given.
///
/// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
/// which also clears the settled due and any reminders scheduled for it.
///
/// Copied from [RecordDoseController].
@ProviderFor(RecordDoseController)
const recordDoseControllerProvider = RecordDoseControllerFamily();

/// Drives the screen where a caregiver logs doses a child has just been given.
///
/// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
/// which also clears the settled due and any reminders scheduled for it.
///
/// Copied from [RecordDoseController].
class RecordDoseControllerFamily extends Family<AsyncValue<RecordDoseState>> {
  /// Drives the screen where a caregiver logs doses a child has just been given.
  ///
  /// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
  /// which also clears the settled due and any reminders scheduled for it.
  ///
  /// Copied from [RecordDoseController].
  const RecordDoseControllerFamily();

  /// Drives the screen where a caregiver logs doses a child has just been given.
  ///
  /// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
  /// which also clears the settled due and any reminders scheduled for it.
  ///
  /// Copied from [RecordDoseController].
  RecordDoseControllerProvider call(
    String childId,
  ) {
    return RecordDoseControllerProvider(
      childId,
    );
  }

  @override
  RecordDoseControllerProvider getProviderOverride(
    covariant RecordDoseControllerProvider provider,
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
  String? get name => r'recordDoseControllerProvider';
}

/// Drives the screen where a caregiver logs doses a child has just been given.
///
/// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
/// which also clears the settled due and any reminders scheduled for it.
///
/// Copied from [RecordDoseController].
class RecordDoseControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    RecordDoseController, RecordDoseState> {
  /// Drives the screen where a caregiver logs doses a child has just been given.
  ///
  /// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
  /// which also clears the settled due and any reminders scheduled for it.
  ///
  /// Copied from [RecordDoseController].
  RecordDoseControllerProvider(
    String childId,
  ) : this._internal(
          () => RecordDoseController()..childId = childId,
          from: recordDoseControllerProvider,
          name: r'recordDoseControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recordDoseControllerHash,
          dependencies: RecordDoseControllerFamily._dependencies,
          allTransitiveDependencies:
              RecordDoseControllerFamily._allTransitiveDependencies,
          childId: childId,
        );

  RecordDoseControllerProvider._internal(
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
  FutureOr<RecordDoseState> runNotifierBuild(
    covariant RecordDoseController notifier,
  ) {
    return notifier.build(
      childId,
    );
  }

  @override
  Override overrideWith(RecordDoseController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecordDoseControllerProvider._internal(
        () => create()..childId = childId,
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
  AutoDisposeAsyncNotifierProviderElement<RecordDoseController, RecordDoseState>
      createElement() {
    return _RecordDoseControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordDoseControllerProvider && other.childId == childId;
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
mixin RecordDoseControllerRef
    on AutoDisposeAsyncNotifierProviderRef<RecordDoseState> {
  /// The parameter `childId` of this provider.
  String get childId;
}

class _RecordDoseControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RecordDoseController,
        RecordDoseState> with RecordDoseControllerRef {
  _RecordDoseControllerProviderElement(super.provider);

  @override
  String get childId => (origin as RecordDoseControllerProvider).childId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
