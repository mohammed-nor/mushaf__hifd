import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/pages/splash_screen.dart';
import 'src/theme/theme_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load persisted theme settings before the app starts so the
  // first frame uses the correct font/size.
  final prefs = await SharedPreferences.getInstance();
  final fontFamily = prefs.getString('font_family') ?? 'System';
  final fontSize = prefs.getDouble('font_size') ?? 18.0;
  final lineSpacing = prefs.getDouble('line_spacing') ?? 1.5;
  final isDarkMode = prefs.getBool('is_dark_mode') ?? true;
  themeSettingsNotifier.value = ThemeSettings(
    fontFamily: fontFamily,
    fontSize: fontSize,
    lineSpacing: lineSpacing,
    isDarkMode: isDarkMode,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildDarkTheme(ThemeSettings settings) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: settings.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: kPrimaryTeal,
        secondary: kSecondaryTeal,
        surface: kDarkBackground,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: kLightBackground,
        ),
        iconTheme: IconThemeData(color: kLightBackground),
      ),
      cardTheme: CardThemeData(
        color: kLightBackground.withAlpha(10),
        shadowColor: const Color.fromARGB(
          255,
          169,
          169,
          169,
        ).withValues(alpha: 0.1),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16 * (settings.fontSize / 18.0),
          color: kLightBackground,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: kLightBackground,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * (settings.fontSize / 18.0),
          color: kLightBackground,
        ),
        headlineLarge: TextStyle(
          fontSize: 30 * (settings.fontSize / 18.0),
          color: kLightBackground,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 27 * (settings.fontSize / 18.0),
          color: kLightBackground,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontSize: 24 * (settings.fontSize / 18.0),
          color: kLightBackground,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 20 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 17 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontSize: 12 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: TextStyle(
          fontSize: 11 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ).apply(fontFamily: settings.fontFamily),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  ThemeData _buildLightTheme(ThemeSettings settings) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: settings.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: kDarkTeal,
        secondary: kTertiaryTeal,
        surface: kLightBackgroundVariant,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: kLightBackground,
        elevation: 2,
        shadowColor: Colors.grey.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: kDarkTeal,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: kDarkTeal),
      ),
      cardTheme: CardThemeData(
        color: kLightBackground,
        shadowColor: Colors.grey.withValues(alpha: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16 * (settings.fontSize / 18.0),
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * (settings.fontSize / 18.0),
          color: Colors.black54,
        ),
        headlineLarge: TextStyle(
          fontSize: 30 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 27 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontSize: 24 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 20 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 17 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontSize: 12 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: TextStyle(
          fontSize: 11 * (settings.fontSize / 18.0),
          color: kDarkTeal,
          fontWeight: FontWeight.bold,
        ),
      ).apply(fontFamily: settings.fontFamily),
      scaffoldBackgroundColor: kLightBackground,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kLightBackground,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'حفظ القرآن',
          theme: settings.isDarkMode
              ? _buildDarkTheme(settings)
              : _buildLightTheme(settings),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'), // Arabic
          ],
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
