import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the font configuration that the user selects in the
/// settings page.  A [ValueNotifier] is used so that the app can
/// reactively rebuild whenever the values change.
class ThemeSettings {
  final String fontFamily;
  final double fontSize;

  ThemeSettings({required this.fontFamily, required this.fontSize});

  ThemeSettings copyWith({String? fontFamily, double? fontSize}) {
    return ThemeSettings(fontFamily: fontFamily ?? this.fontFamily, fontSize: fontSize ?? this.fontSize);
  }
}

/// Global notifier that the rest of the application listens to when
/// theme settings are updated.
final themeSettingsNotifier = ValueNotifier<ThemeSettings>(ThemeSettings(fontFamily: 'Andalus', fontSize: 18.0));

/// Persist the new settings and update [themeSettingsNotifier].
Future<void> updateThemeSettings(String fontFamily, double fontSize) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('font_family', fontFamily);
  await prefs.setDouble('font_size', fontSize);
  themeSettingsNotifier.value = ThemeSettings(fontFamily: fontFamily, fontSize: fontSize);
}
