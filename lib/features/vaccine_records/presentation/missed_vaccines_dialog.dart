import 'package:flutter/material.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';

Future<void> showMissedVaccinesDialog(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      contentPadding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      actionsPadding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFCD2E2E),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              localizations.overdueVaccinesDialogTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        localizations.overdueVaccinesDialogMessage,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
      actions: [
        Center(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F52BA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.actionUnderstand),
          ),
        ),
      ],
    ),
  );
}
