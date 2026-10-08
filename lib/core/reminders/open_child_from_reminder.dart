import 'package:flutter/material.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/features/child/presentation/child_profile_screen.dart';

/// Opens the page of the child a tapped reminder was about.
///
/// Returns whether a page was opened. Nothing opens when the app has no
/// navigator yet or the child has since been deleted; the tap then simply
/// brings the app forward.
Future<bool> openChildFromReminder({
  required NavigatorState? navigator,
  required AppDatabase database,
  required String childId,
}) async {
  if (navigator == null) {
    return false;
  }
  final ChildProfile? child =
      await database.childProfilesDao.getChildProfileById(childId);
  if (child == null || !navigator.mounted) {
    return false;
  }
  navigator.push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => ChildProfileScreen(childId: childId),
    ),
  );
  return true;
}
