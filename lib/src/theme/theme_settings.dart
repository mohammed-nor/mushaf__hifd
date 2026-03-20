import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the font configuration that the user selects in the
/// settings page. A [ValueNotifier] is used so that the app can
/// reactively rebuild whenever the values change.  [lineSpacing]
/// will be applied to the textual versions of the thomuns and can be
/// adjusted separately from the font size.
class ThemeSettings {
  final String fontFamily;
  final double fontSize;
  final double lineSpacing;
  final bool isDarkMode;

  ThemeSettings({
    required this.fontFamily,
    required this.fontSize,
    required this.lineSpacing,
    this.isDarkMode = true,
  });

  ThemeSettings copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineSpacing,
    bool? isDarkMode,
  }) {
    return ThemeSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// Global notifier that the rest of the application listens to when
/// theme settings are updated.
final themeSettingsNotifier = ValueNotifier<ThemeSettings>(
  ThemeSettings(
    fontFamily: 'Andalus',
    fontSize: 18.0,
    lineSpacing: 1.5,
    isDarkMode: true,
  ),
);

/// Persist the new settings and update [themeSettingsNotifier].
Future<void> updateThemeSettings(
  String fontFamily,
  double fontSize,
  double lineSpacing, {
  bool? isDarkMode,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('font_family', fontFamily);
  await prefs.setDouble('font_size', fontSize);
  await prefs.setDouble('line_spacing', lineSpacing);
  if (isDarkMode != null) {
    await prefs.setBool('is_dark_mode', isDarkMode);
  }
  final currentValue = themeSettingsNotifier.value;
  themeSettingsNotifier.value = ThemeSettings(
    fontFamily: fontFamily,
    fontSize: fontSize,
    lineSpacing: lineSpacing,
    isDarkMode: isDarkMode ?? currentValue.isDarkMode,
  );
}

/// Update only the theme mode
Future<void> updateThemeMode(bool isDarkMode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_dark_mode', isDarkMode);
  final currentValue = themeSettingsNotifier.value;
  themeSettingsNotifier.value = ThemeSettings(
    fontFamily: currentValue.fontFamily,
    fontSize: currentValue.fontSize,
    lineSpacing: currentValue.lineSpacing,
    isDarkMode: isDarkMode,
  );
}
