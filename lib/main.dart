import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/pages/splash_screen.dart';
import 'src/theme/theme_settings.dart';
import 'src/services/notification_service.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/utils/responsive.dart';
import 'src/services/progress_service.dart';
import 'dart:io';

// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  NotificationService.initialize();

  // Initialize notifications for revision reminders
  await NotificationService.instance.initializeNotifications();

  // Restore reminders for all previously-revised thomuns.
  // This is essential on Windows (Timers don't survive process exit)
  // and harmless on Android (existing system alarms are kept).
  await NotificationService.instance.rescheduleAllReminders();

  // Initialize launch at startup for Desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );
  }

  // Load progress data globally
  await progressService.load();

  // load persisted theme settings before the app starts so the
  // first frame uses the correct font/size.
  final prefs = await SharedPreferences.getInstance();
  final fontFamily = prefs.getString('font_family') ?? 'System';
  final fontSize = prefs.getDouble('font_size') ?? 18.0;
  final lineSpacing = prefs.getDouble('line_spacing') ?? 1.5;
  final isDarkMode = prefs.getBool('is_dark_mode') ?? true;
  final darkBgTheme = prefs.getString('dark_bg_theme') ?? 'dark_blue';
  final lightBgTheme = prefs.getString('light_bg_theme') ?? 'light_white';
  final darkTextColor = prefs.getString('dark_text_color') ?? 'white';
  final lightTextColor = prefs.getString('light_text_color') ?? 'black';
  final accentColor = prefs.getString('accent_color') ?? 'teal';
  final autostart = prefs.getBool('autostart') ?? false;
  final keepScreenOn = prefs.getBool('keep_screen_on') ?? false;

  // Apply wakelock if enabled
  if (keepScreenOn) {
    WakelockPlus.enable();
  }

  themeSettingsNotifier.value = ThemeSettings(
    fontFamily: fontFamily,
    fontSize: fontSize,
    lineSpacing: lineSpacing,
    isDarkMode: isDarkMode,
    darkBgTheme: darkBgTheme,
    lightBgTheme: lightBgTheme,
    darkTextColor: darkTextColor,
    lightTextColor: lightTextColor,
    accentColor: accentColor,
    autostart: autostart,
    keepScreenOn: keepScreenOn,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildDarkTheme(BuildContext context, ThemeSettings settings) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: settings.fontFamily,
      primaryColor: settings.primaryColor,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: settings.primaryColor,
        secondary: kSecondaryTeal,
        surface: kDarkBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _getGoogleFontOrLocal(
          settings.fontFamily,
          TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: kLightBackground,
            fontSize: ResponsiveUtils.sp(context, 20) * settings.fontScale,
          ),
        ),
        iconTheme: const IconThemeData(color: kLightBackground),
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
      textTheme: _buildTextTheme(context, settings, kLightBackground),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  TextTheme _buildTextTheme(
    BuildContext context,
    ThemeSettings settings,
    Color textColor,
  ) {
    final baseTextTheme = TextTheme(
      bodyLarge: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 16) * settings.fontScale,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 14) * settings.fontScale,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 12) * settings.fontScale,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 30) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 27) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 24) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 20) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 17) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 14) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 14) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 12) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      labelSmall: TextStyle(
        fontSize: ResponsiveUtils.sp(context, 11) * settings.fontScale,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );

    if (GoogleFonts.asMap().containsKey(settings.fontFamily)) {
      try {
        return GoogleFonts.getTextTheme(settings.fontFamily, baseTextTheme);
      } catch (e) {
        debugPrint('Error loading google font ${settings.fontFamily}: $e');
        return baseTextTheme.apply(fontFamily: settings.fontFamily);
      }
    } else {
      return baseTextTheme.apply(fontFamily: settings.fontFamily);
    }
  }

  TextStyle _getGoogleFontOrLocal(String fontFamily, TextStyle baseStyle) {
    if (GoogleFonts.asMap().containsKey(fontFamily)) {
      try {
        return GoogleFonts.getFont(fontFamily, textStyle: baseStyle);
      } catch (e) {
        return baseStyle.copyWith(fontFamily: fontFamily);
      }
    } else {
      return baseStyle.copyWith(fontFamily: fontFamily);
    }
  }

  ThemeData _buildLightTheme(BuildContext context, ThemeSettings settings) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: settings.fontFamily,
      primaryColor: settings.primaryColor,
      colorScheme: ColorScheme.light(
        primary: settings.primaryColor,
        secondary: kTertiaryTeal,
        surface: kLightBackgroundVariant,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: kLightBackground,
        elevation: 2,
        shadowColor: Colors.grey.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _getGoogleFontOrLocal(
          settings.fontFamily,
          TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: kDarkTeal,
            fontSize: ResponsiveUtils.sp(context, 20) * settings.fontScale,
          ),
        ),
        iconTheme: const IconThemeData(color: kDarkTeal),
      ),
      cardTheme: CardThemeData(
        color: kLightBackground,
        shadowColor: Colors.grey.withValues(alpha: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: _buildTextTheme(context, settings, Colors.black87),
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
          navigatorKey: navigatorKey,
          title: 'حفظ القرآن',
          theme: settings.isDarkMode
              ? _buildDarkTheme(context, settings)
              : _buildLightTheme(context, settings),
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
