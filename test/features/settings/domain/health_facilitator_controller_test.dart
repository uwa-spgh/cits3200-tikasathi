import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/features/settings/domain/health_facilitator_controller.dart';

void main() {
  test('controller saves the facilitator and provider emits it', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    await container.read(healthFacilitatorProvider.future);
    final saved = await container
        .read(healthFacilitatorControllerProvider.notifier)
        .save(name: 'Maya', address: 'Ward 4', phone: '9800000000');

    expect(saved, isTrue);
    await pumpEventQueue();
    expect(
      container.read(healthFacilitatorProvider).requireValue?.name,
      'Maya',
    );
  });
}
