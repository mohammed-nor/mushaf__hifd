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

  ThemeSettings({required this.fontFamily, required this.fontSize, required this.lineSpacing});

  ThemeSettings copyWith({String? fontFamily, double? fontSize, double? lineSpacing}) {
    return ThemeSettings(fontFamily: fontFamily ?? this.fontFamily, fontSize: fontSize ?? this.fontSize, lineSpacing: lineSpacing ?? this.lineSpacing);
  }
}

/// Global notifier that the rest of the application listens to when
/// theme settings are updated.
final themeSettingsNotifier = ValueNotifier<ThemeSettings>(ThemeSettings(fontFamily: 'Andalus', fontSize: 18.0, lineSpacing: 1.5));

/// Persist the new settings and update [themeSettingsNotifier].
Future<void> updateThemeSettings(String fontFamily, double fontSize, double lineSpacing) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('font_family', fontFamily);
  await prefs.setDouble('font_size', fontSize);
  await prefs.setDouble('line_spacing', lineSpacing);
  themeSettingsNotifier.value = ThemeSettings(fontFamily: fontFamily, fontSize: fontSize, lineSpacing: lineSpacing);
}
