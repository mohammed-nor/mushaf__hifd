import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// Background theme palette
// ─────────────────────────────────────────────────────────────────────────────

class BgThemeOption {
  final String key;
  final String label;
  final Color start;
  final Color end;
  final bool isDark;
  const BgThemeOption({
    required this.key,
    required this.label,
    required this.start,
    required this.end,
    required this.isDark,
  });
}

const List<BgThemeOption> kBgThemes = [
  BgThemeOption(
    key: 'dark_blue',
    label: 'أزرق داكن',
    start: Color(0xFF1E1E2C),
    end: Color(0xFF12121D),
    isDark: true,
  ),
  BgThemeOption(
    key: 'deep_ocean',
    label: 'المحيط',
    start: Color(0xFF0D1B2A),
    end: Color(0xFF1B3A4B),
    isDark: true,
  ),
  BgThemeOption(
    key: 'forest',
    label: 'الغابة',
    start: Color(0xFF0F2017),
    end: Color(0xFF1A3626),
    isDark: true,
  ),
  BgThemeOption(
    key: 'midnight_purple',
    label: 'بنفسجي',
    start: Color(0xFF1A0A2E),
    end: Color(0xFF2D1259),
    isDark: true,
  ),
  BgThemeOption(
    key: 'ember',
    label: 'الجمر',
    start: Color(0xFF1C0D0D),
    end: Color(0xFF2E1515),
    isDark: true,
  ),
  BgThemeOption(
    key: 'charcoal',
    label: 'فحمي',
    start: Color(0xFF1A1A1A),
    end: Color(0xFF2D2D2D),
    isDark: true,
  ),
  BgThemeOption(
    key: 'light_white',
    label: 'أبيض',
    start: Color(0xFFF5F5F5),
    end: Color(0xFFFFFFFF),
    isDark: false,
  ),
  BgThemeOption(
    key: 'light_cream',
    label: 'كريمي',
    start: Color(0xFFFFF8F0),
    end: Color(0xFFFDF3E3),
    isDark: false,
  ),
  BgThemeOption(
    key: 'light_mint',
    label: 'نعناعي',
    start: Color(0xFFE8F5F0),
    end: Color(0xFFF0FBF7),
    isDark: false,
  ),
  BgThemeOption(
    key: 'light_sky',
    label: 'سماوي',
    start: Color(0xFFE8F4FD),
    end: Color(0xFFF0F8FF),
    isDark: false,
  ),
  BgThemeOption(
    key: 'light_blush',
    label: 'وردي خفيف',
    start: Color(0xFFFFF0F3),
    end: Color(0xFFFDE8EC),
    isDark: false,
  ),
  BgThemeOption(
    key: 'light_lavender',
    label: 'خزامى',
    start: Color(0xFFF3F0FF),
    end: Color(0xFFEDE8FF),
    isDark: false,
  ),
];

BgThemeOption bgThemeForKey(String key) {
  return kBgThemes.firstWhere(
    (t) => t.key == key,
    orElse: () => kBgThemes.first,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Text color palette
// ─────────────────────────────────────────────────────────────────────────────

class TextColorOption {
  final String key;
  final String label;
  final Color color;
  final bool isDark;
  const TextColorOption({
    required this.key,
    required this.label,
    required this.color,
    required this.isDark,
  });
}

const List<TextColorOption> kTextColors = [
  // ── Dark mode options (Light colors) ───────────────────────────────────
  TextColorOption(
    key: 'white',
    label: 'أبيض',
    color: Colors.white,
    isDark: true,
  ),
  TextColorOption(
    key: 'teal_light',
    label: 'تيل',
    color: Color(0xFF1ABC9C),
    isDark: true,
  ),
  TextColorOption(
    key: 'gold',
    label: 'ذهبي',
    color: Color(0xFFFFD700),
    isDark: true,
  ),
  TextColorOption(
    key: 'cyan',
    label: 'سماوي',
    color: Color(0xFF00FFFF),
    isDark: true,
  ),
  TextColorOption(
    key: 'silver',
    label: 'فضي',
    color: Color(0xFFC0C0C0),
    isDark: true,
  ),
  // ── Light mode options (Dark colors) ───────────────────────────────────
  TextColorOption(
    key: 'black',
    label: 'أسود',
    color: Colors.black,
    isDark: false,
  ),
  TextColorOption(
    key: 'teal_dark',
    label: 'تيل داكن',
    color: Color(0xFF008080),
    isDark: false,
  ),
  TextColorOption(
    key: 'navy',
    label: 'كحلي',
    color: Color(0xFF000080),
    isDark: false,
  ),
  TextColorOption(
    key: 'maroon',
    label: 'عنابي',
    color: Color(0xFF800000),
    isDark: false,
  ),
  TextColorOption(
    key: 'grey_dark',
    label: 'رمادي داكن',
    color: Color(0xFF333333),
    isDark: false,
  ),
];

TextColorOption textColorForKey(String key) {
  return kTextColors.firstWhere(
    (t) => t.key == key,
    orElse: () => kTextColors.firstWhere((t) => t.isDark),
  );
}

TextColorOption lightTextColorForKey(String key) {
  return kTextColors.firstWhere(
    (t) => t.key == key,
    orElse: () => kTextColors.firstWhere((t) => !t.isDark),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeSettings model
// ─────────────────────────────────────────────────────────────────────────────

class ThemeSettings {
  final String fontFamily;
  final double fontSize;
  final double lineSpacing;
  final bool isDarkMode;
  final String darkBgTheme;
  final String lightBgTheme;
  final String darkTextColor;
  final String lightTextColor;
  final bool autostart;
  final bool keepScreenOn;

  ThemeSettings({
    required this.fontFamily,
    required this.fontSize,
    required this.lineSpacing,
    this.isDarkMode = true,
    this.darkBgTheme = 'dark_blue',
    this.lightBgTheme = 'light_white',
    this.darkTextColor = 'white',
    this.lightTextColor = 'black',
    this.autostart = false,
    this.keepScreenOn = false,
  });

  ThemeSettings copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineSpacing,
    bool? isDarkMode,
    String? darkBgTheme,
    String? lightBgTheme,
    String? darkTextColor,
    String? lightTextColor,
    bool? autostart,
    bool? keepScreenOn,
  }) {
    return ThemeSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      darkBgTheme: darkBgTheme ?? this.darkBgTheme,
      lightBgTheme: lightBgTheme ?? this.lightBgTheme,
      darkTextColor: darkTextColor ?? this.darkTextColor,
      lightTextColor: lightTextColor ?? this.lightTextColor,
      autostart: autostart ?? this.autostart,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }

  List<Color> get backgroundGradient {
    final key = isDarkMode ? darkBgTheme : lightBgTheme;
    final theme = bgThemeForKey(key);
    return [theme.start, theme.end];
  }

  Color get textColor {
    if (isDarkMode) {
      return textColorForKey(darkTextColor).color;
    } else {
      return lightTextColorForKey(lightTextColor).color;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Global notifier
// ─────────────────────────────────────────────────────────────────────────────

final themeSettingsNotifier = ValueNotifier<ThemeSettings>(
  ThemeSettings(
    fontFamily: 'System',
    fontSize: 18.0,
    lineSpacing: 1.5,
    isDarkMode: true,
    autostart: false,
    keepScreenOn: false,
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Persistence helpers
// ─────────────────────────────────────────────────────────────────────────────

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
  final current = themeSettingsNotifier.value;
  themeSettingsNotifier.value = ThemeSettings(
    fontFamily: fontFamily,
    fontSize: fontSize,
    lineSpacing: lineSpacing,
    isDarkMode: isDarkMode ?? current.isDarkMode,
    darkBgTheme: current.darkBgTheme,
    lightBgTheme: current.lightBgTheme,
    darkTextColor: current.darkTextColor,
    lightTextColor: current.lightTextColor,
  );
}

Future<void> updateThemeMode(bool isDarkMode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_dark_mode', isDarkMode);
  final current = themeSettingsNotifier.value;
  themeSettingsNotifier.value = current.copyWith(isDarkMode: isDarkMode);
}

Future<void> updateBgTheme({
  String? darkBgTheme,
  String? lightBgTheme,
}) async {
  final prefs = await SharedPreferences.getInstance();
  if (darkBgTheme != null) {
    await prefs.setString('dark_bg_theme', darkBgTheme);
  }
  if (lightBgTheme != null) {
    await prefs.setString('light_bg_theme', lightBgTheme);
  }
  themeSettingsNotifier.value = themeSettingsNotifier.value.copyWith(
    darkBgTheme: darkBgTheme,
    lightBgTheme: lightBgTheme,
  );
}

Future<void> updateTextColor({
  String? darkTextColor,
  String? lightTextColor,
}) async {
  final prefs = await SharedPreferences.getInstance();
  if (darkTextColor != null) {
    await prefs.setString('dark_text_color', darkTextColor);
  }
  if (lightTextColor != null) {
    await prefs.setString('light_text_color', lightTextColor);
  }
  themeSettingsNotifier.value = themeSettingsNotifier.value.copyWith(
    darkTextColor: darkTextColor,
    lightTextColor: lightTextColor,
  );
}

Future<void> updateAutostart(bool autostart) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('autostart', autostart);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (autostart) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  themeSettingsNotifier.value = themeSettingsNotifier.value.copyWith(
    autostart: autostart,
  );
}

Future<void> updateKeepScreenOn(bool keepScreenOn) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('keep_screen_on', keepScreenOn);

  // We toggle the wakelock here. It works on Android/iOS/Web.
  // On Desktop it might have limited support depending on the platform.
  try {
    await WakelockPlus.toggle(enable: keepScreenOn);
  } catch (e) {
    debugPrint('Wakelock error: $e');
  }

  themeSettingsNotifier.value = themeSettingsNotifier.value.copyWith(
    keepScreenOn: keepScreenOn,
  );
}
