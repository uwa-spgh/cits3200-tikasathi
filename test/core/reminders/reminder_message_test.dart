import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/reminders/reminder_message.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

void main() {
  final DateTime dueDate = DateTime(2026, 10, 4);

  setUpAll(() => ensureReminderDateFormatting());

  ReminderMessage messageFor(
    ReminderKind kind, {
    AppLanguage language = AppLanguage.english,
    String childName = 'Aarav',
    String vaccineCode = 'PENTA',
    int doseNumber = 2,
  }) {
    return buildReminderMessage(
      localizations: lookupAppLocalizations(language.locale),
      languageCode: language.code,
      childName: childName,
      vaccineCode: vaccineCode,
      doseNumber: doseNumber,
      dueDate: dueDate,
      kind: kind,
    );
  }

  group('buildReminderMessage', () {
    // The client brief fixes this sentence. Changing it needs their sign-off,
    // so the test states it in full rather than matching loosely.
    test('uses the client wording for an upcoming dose', () {
      for (final ReminderKind kind in <ReminderKind>[
        ReminderKind.advance,
        ReminderKind.preparation,
        ReminderKind.sameDay,
      ]) {
        expect(
          messageFor(kind).body,
          'For Aarav: Your child is due for PENTA (Dose 2) on 4 October 2026. '
          'Please visit your nearest health post or immunisation clinic.',
          reason: 'wording for $kind',
        );
      }
    });

    // Also client-fixed wording.
    test('uses the client wording once a dose is overdue', () {
      expect(
        messageFor(ReminderKind.overdueRecurring).body,
        'For Aarav: PENTA (Dose 2) is overdue. Contact your nearest health '
        'facility for catch-up vaccination.',
      );
    });

    test('names the child, the vaccine and the dose in every message', () {
      for (final ReminderKind kind in ReminderKind.values) {
        final ReminderMessage message = messageFor(kind);
        expect(message.body, contains('Aarav'), reason: 'child name for $kind');
        expect(
          message.body,
          contains('PENTA (Dose 2)'),
          reason: 'vaccine for $kind',
        );
        expect(message.title, isNotEmpty, reason: 'title for $kind');
      }
    });

    test('tells the caregiver which child each reminder is about', () {
      expect(messageFor(ReminderKind.sameDay, childName: 'Sita').body,
          startsWith('For Sita:'));
      expect(messageFor(ReminderKind.sameDay, childName: 'Bikash').body,
          startsWith('For Bikash:'));
    });

    // The follow-ups have no client-supplied wording. The brief only requires
    // the missed vaccine, why finishing matters, and catch-up guidance.
    test('the follow-up wording carries what the brief asks for', () {
      final String dayAfter = messageFor(ReminderKind.followUpDay).body;
      expect(dayAfter, contains('PENTA (Dose 2)'));
      expect(dayAfter, contains('protected'));

      final String weekAfter = messageFor(ReminderKind.followUpWeek).body;
      expect(weekAfter, contains('PENTA (Dose 2)'));
      expect(weekAfter, contains('catch-up'));
    });

    test('distinguishes upcoming, missed and overdue by title', () {
      expect(
        messageFor(ReminderKind.sameDay).title,
        isNot(messageFor(ReminderKind.followUpDay).title),
      );
      expect(
        messageFor(ReminderKind.followUpDay).title,
        isNot(messageFor(ReminderKind.overdueRecurring).title),
      );
    });

    group('Nepali', () {
      test('uses the Nepali copy for every kind', () {
        for (final ReminderKind kind in ReminderKind.values) {
          final ReminderMessage nepali =
              messageFor(kind, language: AppLanguage.nepali);
          final ReminderMessage english = messageFor(kind);

          expect(nepali.body, isNot(english.body), reason: 'body for $kind');
          expect(nepali.body, contains('Aarav'));
          expect(nepali.body, contains('PENTA'));
        }
      });

      test('keeps the vaccine label in the Nepali word for dose', () {
        expect(
          messageFor(ReminderKind.sameDay, language: AppLanguage.nepali).body,
          contains('खुराक'),
        );
      });
    });
  });
}
