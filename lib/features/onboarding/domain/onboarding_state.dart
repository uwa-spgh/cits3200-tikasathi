import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
import 'package:uuid/uuid.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

@freezed
class OnboardingStateData with _$OnboardingStateData {
  const factory OnboardingStateData({
    @Default(AppLanguage.nepali) AppLanguage selectedLanguage,
    @Default('') String caregiverName,
    @Default('') String caregiverPhone,
    @Default('') String caregiverAddress,
    @Default('') String childName,
    DateTime? childDob,
    @Default('Girl') String childSex,
    @Default(false) bool isSaving,
    String? error,
  }) = _OnboardingStateData;
}

@riverpod
class OnboardingController extends _$OnboardingController {
  Future<String?>? _activeFinishSetup;
  String? _createdChildId;

  @override
  OnboardingStateData build() {
    return const OnboardingStateData();
  }

  void updateLanguage(AppLanguage language) {
    state = state.copyWith(selectedLanguage: language);
  }

  void updateCaregiverInfo({
    required String name,
    required String phone,
    required String address,
  }) {
    if (state.caregiverName != name ||
        state.caregiverPhone != phone ||
        state.caregiverAddress != address) {
      _createdChildId = null;
    }
    state = state.copyWith(
      caregiverName: name,
      caregiverPhone: phone,
      caregiverAddress: address,
    );
  }

  void updateChildInfo({
    required String name,
    required DateTime dob,
    required String sex,
  }) {
    if (state.childName != name ||
        state.childDob != dob ||
        state.childSex != sex) {
      _createdChildId = null;
    }
    state = state.copyWith(
      childName: name,
      childDob: dob,
      childSex: sex,
    );
  }

  Future<String?> finishSetup() {
    final activeFinishSetup = _activeFinishSetup;
    if (activeFinishSetup != null) {
      return activeFinishSetup;
    }

    final Future<String?> operation = _finishSetup();
    _activeFinishSetup = operation;
    operation.then<void>(
      (_) {
        if (identical(_activeFinishSetup, operation)) {
          _activeFinishSetup = null;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_activeFinishSetup, operation)) {
          _activeFinishSetup = null;
        }
      },
    );
    return operation;
  }

  Future<void> cancelInitialOnboardingVaccineSetup() async {
    final String? childId = _createdChildId;
    if (childId != null) {
      final db = ref.read(appDatabaseProvider);
      await db.childProfilesDao.deleteChildProfile(childId);
    }

    await ref
        .read(secureStorageServiceProvider)
        .writeOnboardingCompleted(false);
    _createdChildId = null;
  }

  Future<String?> _finishSetup() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final DateTime? childDob = state.childDob;
      if (state.childName.isNotEmpty && childDob == null) {
        throw StateError('A valid child date of birth is required');
      }

      final secureStorage = ref.read(secureStorageServiceProvider);

      // 1. Save Caregiver
      await secureStorage.saveCaregiverProfile(
        name: state.caregiverName,
        phone: state.caregiverPhone,
        address: state.caregiverAddress,
      );

      // 2. Save Child
      if (state.childName.isNotEmpty && childDob != null) {
        final db = ref.read(appDatabaseProvider);
        _createdChildId ??= const Uuid().v4();
        final childId = _createdChildId!;
        final existingChild =
            await db.childProfilesDao.getChildProfileById(childId);
        if (existingChild == null) {
          await db.childProfilesDao.insertChildProfile(
            ChildProfilesCompanion.insert(
              id: childId,
              name: state.childName,
              dateOfBirth: childDob,
              sex: state.childSex,
            ),
          );
        }
        await db.vaccinationDuesDao.recalculateDuesForChild(childId);
      }

      // 3. Save language and mark onboarding as completed.
      final bool languageSaved = await ref
          .read(languageControllerProvider.notifier)
          .setLanguage(state.selectedLanguage);
      if (!languageSaved) {
        throw StateError('Failed to save language preference');
      }
      await secureStorage.setOnboardingCompleted();

      state = state.copyWith(isSaving: false);
      return _createdChildId ?? 'completed_without_child';
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }
}
