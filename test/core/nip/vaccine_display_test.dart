import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_display.dart';

void main() {
  test('omits the dose number for catalogue vaccines with one dose', () {
    final localizations = lookupAppLocalizations(const Locale('en'));

    expect(
      formatVaccineDisplayName(localizations, 'BCG', 1),
      'BCG',
    );
    expect(vaccineHasMultipleDoses('BCG'), isFalse);
  });

  test(
      'keeps the localized dose number for catalogue vaccines with multiple doses',
      () {
    final localizations = lookupAppLocalizations(const Locale('en'));

    expect(
      formatVaccineDisplayName(localizations, 'PENTA', 2),
      'PENTA (Dose 2)',
    );
    expect(vaccineHasMultipleDoses('PENTA'), isTrue);
  });

  test('uses the existing Nepali dose wording for multi-dose vaccines', () {
    final localizations = lookupAppLocalizations(const Locale('ne'));

    expect(
      formatVaccineDisplayName(localizations, 'PENTA', 2),
      'PENTA (खुराक 2)',
    );
  });
}
