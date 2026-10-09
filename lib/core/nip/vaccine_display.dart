import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';

bool vaccineHasMultipleDoses(String vaccineCode) {
  return (nipCatalogue[vaccineCode]?.length ?? 0) > 1;
}

bool vaccineHasSingleDose(String vaccineCode) {
  return nipCatalogue[vaccineCode]?.length == 1;
}

String formatVaccineDisplayName(
  AppLocalizations localizations,
  String vaccineCode,
  int doseNumber,
) {
  if (vaccineHasSingleDose(vaccineCode)) {
    return vaccineCode;
  }
  return '$vaccineCode (${localizations.dose} $doseNumber)';
}
