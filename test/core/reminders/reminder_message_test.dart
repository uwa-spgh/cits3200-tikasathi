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
    String? facility,
  }) {
    return buildReminderMessage(
      localizations: lookupAppLocalizations(language.locale),
      languageCode: language.code,
      childName: childName,
      vaccineCode: vaccineCode,
      doseNumber: doseNumber,
      dueDate: dueDate,
      kind: kind,
      facility: facility,
    );
  }

  group('buildReminderMessage', () {
    // The client brief fixes this sentence. Changing it needs their sign-off,
    // so the tests state it in full rather than matching loosely.
    const String clientDueSentence =
        'Your child is due for PENTA (Dose 2) on 4 October 2026. '
        'Please visit your nearest health post or immunisation clinic.';

    group('3-touch approach', () {
      test('a week before sends the client wording on its own', () {
        expect(messageFor(ReminderKind.advance).body, clientDueSentence);
      });

      test('the day before says tomorrow is the vaccination day', () {
        expect(
          messageFor(ReminderKind.preparation).body,
          'Tomorrow is the scheduled vaccination day. $clientDueSentence',
        );
      });

      test("the day itself says it is the child's vaccination day", () {
        expect(
          messageFor(ReminderKind.sameDay).body,
          "Today is your child's vaccination day. $clientDueSentence",
        );
      });

      test('each touch reads differently', () {
        final Set<String> bodies = <String>{
          messageFor(ReminderKind.advance).body,
          messageFor(ReminderKind.preparation).body,
          messageFor(ReminderKind.sameDay).body,
        };
        expect(bodies, hasLength(3));
      });

      test('each touch reads differently in Nepali too', () {
        final Set<String> bodies = <String>{
          for (final ReminderKind kind in <ReminderKind>[
            ReminderKind.advance,
            ReminderKind.preparation,
            ReminderKind.sameDay,
          ])
            messageFor(kind, language: AppLanguage.nepali).body,
        };
        expect(bodies, hasLength(3));
      });
    });

    // Also client-fixed wording.
    test('uses the client wording once a dose is overdue', () {
      expect(
        messageFor(ReminderKind.overdueRecurring).body,
        'PENTA (Dose 2) is overdue. Contact your nearest health facility '
        'for catch-up vaccination.',
      );
    });

    test('names the child in the title and the vaccine in the body', () {
      for (final ReminderKind kind in ReminderKind.values) {
        final ReminderMessage message = messageFor(kind);
        expect(message.title, contains('Aarav'), reason: 'child for $kind');
        expect(
          message.body,
          contains('PENTA (Dose 2)'),
          reason: 'vaccine for $kind',
        );
      }
    });

    // The brief's fixed sentence says "your child", so with two children the
    // bodies are identical; only the title tells them apart.
    test('tells two children apart by title, not body', () {
      final ReminderMessage sita =
          messageFor(ReminderKind.sameDay, childName: 'Sita');
      final ReminderMessage bikash =
          messageFor(ReminderKind.sameDay, childName: 'Bikash');

      expect(sita.body, bikash.body);
      expect(sita.title, contains('Sita'));
      expect(bikash.title, contains('Bikash'));
    });

    test('keeps the child name out of every body', () {
      for (final ReminderKind kind in ReminderKind.values) {
        expect(messageFor(kind).body, isNot(contains('Aarav')),
            reason: 'body for $kind');
      }
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
          expect(nepali.title, contains('Aarav'));
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

  group('saved health facility', () {
    const String facility = 'Bhaktapur Health Post, Ward 4, 9812345678';
    const String sentence = 'Your saved health facility: $facility.';

    test('tells the caregiver where to go before the due date', () {
      for (final ReminderKind kind in <ReminderKind>[
        ReminderKind.advance,
        ReminderKind.preparation,
        ReminderKind.sameDay,
      ]) {
        expect(
          messageFor(kind, facility: facility).body,
          endsWith(' $sentence'),
          reason: 'facility for $kind',
        );
      }
    });

    // The facility is its own sentence, so the client's wording before it is
    // unchanged.
    test("keeps the client's sentence intact ahead of the facility", () {
      expect(
        messageFor(ReminderKind.advance, facility: facility).body,
        '${messageFor(ReminderKind.advance).body} $sentence',
      );
    });

    test('is not added to missed or overdue reminders', () {
      for (final ReminderKind kind in <ReminderKind>[
        ReminderKind.followUpDay,
        ReminderKind.followUpWeek,
        ReminderKind.overdueRecurring,
      ]) {
        expect(
          messageFor(kind, facility: facility).body,
          messageFor(kind).body,
          reason: 'no facility for $kind',
        );
      }
    });

    test('is left out when nothing is saved', () {
      expect(
        messageFor(ReminderKind.sameDay).body,
        isNot(contains('health facility:')),
      );
    });

    test('is in Nepali for a Nepali caregiver', () {
      expect(
        messageFor(
          ReminderKind.sameDay,
          language: AppLanguage.nepali,
          facility: facility,
        ).body,
        endsWith('स्वास्थ्य संस्था: $facility।'),
      );
    });
  });

  group('describeFacility', () {
    test('joins the saved details', () {
      expect(
        describeFacility(
          name: 'Bhaktapur Health Post',
          address: 'Ward 4',
          phone: '9812345678',
        ),
        'Bhaktapur Health Post, Ward 4, 9812345678',
      );
    });

    test('skips blank details', () {
      expect(
        describeFacility(
            name: 'Bhaktapur Health Post', address: '  ', phone: null),
        'Bhaktapur Health Post',
      );
    });

    test('gives nothing when nothing is saved', () {
      expect(describeFacility(), isNull);
      expect(describeFacility(name: '', address: ' ', phone: ''), isNull);
    });
  });
}
