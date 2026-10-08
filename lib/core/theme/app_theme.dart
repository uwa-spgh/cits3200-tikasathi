import 'package:flutter/material.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';

/// The centralised app theme for TikaSathi.
///
/// All feature screens should use `Theme.of(context)` to access these values
/// rather than defining inline styles. This ensures visual consistency across
/// the entire application.
class AppTheme {
  AppTheme._();

  /// Primary seed colour — used by Material 3 to derive the full palette.
  static const Color _seedColor = Color(0xFF0D47A1);

  /// Semantic status color for "up to date" vaccination states.
  static const Color background = Color(0xFFF5F9FC);
  static const Color appBarTitle = Color(0xFF11284F);
  static const Color statusUpToDate = Color(0xFF2E8B57);
  static const Color statusUpToDateText = Color(0xFF136539);

  /// Light theme (default).
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
    ),
    useMaterial3: true,
    // Large touch targets for low-literacy / accessibility users
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );

  /// Dark theme (optional — can be toggled by the user later).
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );
}

/// A centralised basic scaffold structure for TikaSathi.
/// 
/// Consists of a scaffold with a max width of 560 logical pixels, alongside an app bar with a back button, title, and read aloud button.
/// A bottom navigation bar can also be added.
class BasicScaffold extends StatelessWidget {
  const BasicScaffold({required this.title, required this.body, this.bottomNavBar, this.textGetter, this.haveReadAloud = true, super.key});

  final String title;
  final Widget body;
  final Widget? bottomNavBar;
  final String Function()? textGetter;
  final bool haveReadAloud;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: AppTheme.background,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SafeArea(child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.appBarBack,
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.appBarTitle
              )
            ),
            actions: haveReadAloud ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ReadAloudButton(
                  tooltip: l10n.childReadAloudTooltip,
                  unavailableMessage: l10n.childReadAloudUnavailable,
                  textGetter: textGetter
                )
              )
            ] : [],
          ),
          body: body,
          bottomNavigationBar: bottomNavBar,
        ))
      )
    );
  }
}