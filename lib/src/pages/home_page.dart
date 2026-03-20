import 'package:flutter/material.dart';
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
                  ? const [Color(0xFF1E1E2C), Color(0xFF12121D)]
                  : [Colors.grey[50]!, Colors.grey[100]!],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              backgroundColor: settings.isDarkMode
                  ? const Color(0xFF1E1E2C).withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              height: MediaQuery.of(context).size.height * 0.08,
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.5),
              surfaceTintColor: settings.isDarkMode
                  ? const Color(0xFF1ABC9C).withOpacity(0.1)
                  : const Color(0xFF0D7377).withOpacity(0.1),
              indicatorColor: settings.isDarkMode
                  ? const Color(0xFF1ABC9C).withOpacity(0.2)
                  : const Color(0xFF0D7377).withOpacity(0.2),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.mic_outlined),
                  selectedIcon: Icon(Icons.mic, color: Color(0xFF1ABC9C)),
                  label: 'الإستظهار',
                ),
                NavigationDestination(
                  icon: Icon(Icons.text_snippet_outlined),
                  selectedIcon: Icon(
                    Icons.text_snippet,
                    color: Color(0xFF1ABC9C),
                  ),
                  label: 'الحفظ و التلاوة',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: Color(0xFF1ABC9C)),
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
