import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/pages/splash_screen.dart';
import 'src/theme/theme_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load persisted theme settings before the app starts so the
  // first frame uses the correct font/size.
  final prefs = await SharedPreferences.getInstance();
  final fontFamily = prefs.getString('font_family') ?? 'Andalus';
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
        primary: Color(0xFF64FFDA),
        secondary: Color(0xFF1DE9B6),
        surface: Color(0xFF1E1E2C),
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
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withAlpha(10),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16 * (settings.fontSize / 18.0),
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * (settings.fontSize / 18.0),
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 30 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 27 * (settings.fontSize / 18.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontSize: 24 * (settings.fontSize / 18.0),
          color: Colors.white,
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
        primary: Color(0xFF0D7377),
        secondary: Color(0xFF14919B),
        surface: Color(0xFFF5F5F5),
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: const Color(0xFF0D7377),
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D7377)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.2),
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
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 27 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontSize: 24 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 20 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 17 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        labelMedium: TextStyle(
          fontSize: 12 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
        labelSmall: TextStyle(
          fontSize: 11 * (settings.fontSize / 18.0),
          color: const Color(0xFF0D7377),
          fontWeight: FontWeight.bold,
        ),
      ).apply(fontFamily: settings.fontFamily),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
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
