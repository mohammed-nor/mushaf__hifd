import 'package:flutter/material.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/pages/recite_page.dart';
import 'package:mushaf_hifd/src/pages/learn2_page.dart';
import 'package:mushaf_hifd/src/pages/settings_page.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';

/// The root widget that hosts the bottom navigation bar and switches
/// between the primary screens of the application (recite, text
/// learning, settings).
class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    RecitePage(),
    Learn2Page(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: settings.isDarkMode
                  ? const [kDarkBackground, kDarkBackgroundVariant]
                  : [Colors.grey[50]!, kLightBackground],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              backgroundColor: settings.isDarkMode
                  ? kDarkBackground.withValues(alpha: 0.95)
                  : kLightBackground.withValues(alpha: 0),
              height: MediaQuery.of(context).size.height * 0.07,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0),
              surfaceTintColor: settings.isDarkMode
                  ? kPrimaryTeal.withValues(alpha: 0.1)
                  : kDarkTeal.withValues(alpha: 0),
              indicatorColor: settings.isDarkMode
                  ? kPrimaryTeal.withValues(alpha: 0.2)
                  : kDarkTeal.withValues(alpha: 0.2),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.mic_outlined),
                  selectedIcon: Icon(Icons.mic, color: kPrimaryTeal),
                  label: 'الإستظهار',
                ),
                NavigationDestination(
                  icon: Icon(Icons.text_snippet_outlined),
                  selectedIcon: Icon(Icons.text_snippet, color: kPrimaryTeal),
                  label: 'الحفظ و التلاوة',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: kPrimaryTeal),
                  label: 'الإعدادات',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
