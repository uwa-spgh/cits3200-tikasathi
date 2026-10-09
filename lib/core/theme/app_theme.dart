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

/// A centralised basic app bar for TikaSathi.
///
/// [title] is the title of the app bar.
/// [textGetter] is passed to the [ReadAloudButton]; if it is null, the button will attempt to read all visible text instead.
/// [isMainTitle] determines the font of the title, where true corresponds to a larger and bolder font. By default it is false.
/// [haveBackButton] determines if the back button is on the app bar. By default it is true.
/// [haveReadAloudButton] determines if the [ReadAloudButton] is on the app bar. By default it is true.
class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BasicAppBar(
      {this.title,
      this.textGetter,
      this.actions,
      this.isMainTitle = false,
      this.haveBackButton = true,
      this.haveReadAloudButton = true,
      super.key});

  final String? title;
  final String Function()? textGetter;
  final List<Widget>? actions;
  final bool isMainTitle;
  final bool haveBackButton;
  final bool haveReadAloudButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final backButton = haveBackButton
        ? IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.appBarBack,
          )
        : null;

    final titleWidget = title != null
        ? Text(title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: isMainTitle ? FontWeight.w800 : FontWeight.w700,
                color: AppTheme.appBarTitle))
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: backButton,
      title: titleWidget,
      actions: haveReadAloudButton
          ? [
              ...?actions,
              Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ReadAloudButton(
                      tooltip: l10n.childReadAloudTooltip,
                      unavailableMessage: l10n.childReadAloudUnavailable,
                      textGetter: textGetter))
            ]
          : actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
