import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/main.dart';

import 'helpers/fake_settings_repository.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  testWidgets('App boots into shell with bottom navigation',
      (WidgetTester tester) async {
    final mockStorage = MockSecureStorageService();
    when(() => mockStorage.hasCompletedOnboarding())
        .thenAnswer((_) async => true);

    // Wrap in ProviderScope as required by Riverpod
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
          secureStorageServiceProvider.overrideWithValue(mockStorage),
          settingsRepositoryProvider.overrideWith(
            (ref) => FakeSettingsRepository(),
          ),
        ],
        child: const TikaSathiApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigationBar), findsOneWidget);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
  });
}
