import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/pages/home_page.dart';
import 'src/theme/theme_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load persisted theme settings before the app starts so the
  // first frame uses the correct font/size.
  final prefs = await SharedPreferences.getInstance();
  final fontFamily = prefs.getString('font_family') ?? 'Andalus';
  final fontSize = prefs.getDouble('font_size') ?? 18.0;
  themeSettingsNotifier.value = ThemeSettings(
    fontFamily: fontFamily,
    fontSize: fontSize,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'حفظ القرآن',
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: settings.fontFamily,
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF64FFDA), // Teal accent
              secondary: Color(0xFF1DE9B6),
              surface: Color(0xFF1E1E2C), // Deep card background
            ),
            useMaterial3: true,
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
                fontSize: 32 * (settings.fontSize / 18.0),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: TextStyle(
                fontSize: 28 * (settings.fontSize / 18.0),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              headlineSmall: TextStyle(
                fontSize: 24 * (settings.fontSize / 18.0),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: TextStyle(
                fontSize: 22 * (settings.fontSize / 18.0),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                fontSize: 16 * (settings.fontSize / 18.0),
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
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'), // Arabic
          ],
          home: const MainHomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
