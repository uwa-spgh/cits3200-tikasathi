import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:uuid/uuid.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

@freezed
class OnboardingStateData with _$OnboardingStateData {
  const factory OnboardingStateData({
    @Default('np') String selectedLanguage,
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
  @override
  OnboardingStateData build() {
    return const OnboardingStateData();
  }

  void updateLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void updateCaregiverInfo({
    required String name,
    required String phone,
    required String address,
  }) {
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
    state = state.copyWith(
      childName: name,
      childDob: dob,
      childSex: sex,
    );
  }

  Future<bool> finishSetup() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final secureStorage = ref.read(secureStorageServiceProvider);

      // 1. Save Caregiver
      await secureStorage.saveCaregiverProfile(
        name: state.caregiverName,
        phone: state.caregiverPhone,
        address: state.caregiverAddress,
      );

      // 2. Save Child
      if (state.childName.isNotEmpty && state.childDob != null) {
        final db = ref.read(appDatabaseProvider);
        final id = const Uuid().v4();

        await db.childProfilesDao.insertChildProfile(
          ChildProfilesCompanion.insert(
            id: id,
            name: state.childName,
            dateOfBirth: state.childDob!,
            sex: state.childSex,
          ),
        );
      }

      // 3. Save Language & Mark completed
      await secureStorage.saveLanguage(state.selectedLanguage);
      await secureStorage.setOnboardingCompleted();

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
