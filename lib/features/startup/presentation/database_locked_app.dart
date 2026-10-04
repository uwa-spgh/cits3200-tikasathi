import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

/// Shown instead of the app when the encrypted database has lost its key.
///
/// The data cannot be recovered, so the only way forward is to start fresh.
class DatabaseLockedApp extends ConsumerWidget {
  const DatabaseLockedApp({super.key, required this.onStartFresh});

  /// Erases the unreadable data. Throws if it could not.
  final Future<void> Function() onStartFresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale =
        ref.watch(languageControllerProvider).asData?.value.locale ??
            AppLanguage.nepali.locale;
    return MaterialApp(
      title: 'TikaSathi',
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: DatabaseLockedScreen(onStartFresh: onStartFresh),
    );
  }
}

class DatabaseLockedScreen extends StatefulWidget {
  const DatabaseLockedScreen({super.key, required this.onStartFresh});

  final Future<void> Function() onStartFresh;

  @override
  State<DatabaseLockedScreen> createState() => _DatabaseLockedScreenState();
}

class _DatabaseLockedScreenState extends State<DatabaseLockedScreen> {
  bool _working = false;
  bool _failed = false;

  Future<void> _startFresh() async {
    setState(() {
      _working = true;
      _failed = false;
    });
    try {
      await widget.onStartFresh();
    } catch (_) {
      if (mounted) {
        setState(() {
          _working = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Icon(Icons.lock_outline,
                    size: 64, color: Color(0xFF0F52BA)),
                const SizedBox(height: 24),
                Text(
                  localizations.databaseLockedTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.databaseLockedMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Color(0xFF334155),
                  ),
                ),
                if (_failed) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    localizations.databaseLockedError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  key: const Key('database-locked-start-fresh'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _working ? null : _startFresh,
                  child: _working
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(localizations.databaseLockedAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
