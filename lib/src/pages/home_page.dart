import 'package:flutter/material.dart';
import 'package:mushaf_hifd/src/pages/recite_page.dart';
import 'package:mushaf_hifd/src/pages/learn2_page.dart';
import 'package:mushaf_hifd/src/pages/settings_page.dart';

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

  static const List<Widget> _pages = <Widget>[RecitePage(), Learn2Page(), SettingsPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E1E2C), Color(0xFF12121D)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF1E1E2C).withOpacity(0.95),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
          surfaceTintColor: const Color(0xFF64FFDA).withOpacity(0.1),
          indicatorColor: const Color(0xFF64FFDA).withOpacity(0.2),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.mic_outlined),
              selectedIcon: Icon(Icons.mic, color: Color(0xFF64FFDA)),
              label: 'الإستظهار',
            ),
            NavigationDestination(
              icon: Icon(Icons.text_snippet_outlined),
              selectedIcon: Icon(Icons.text_snippet, color: Color(0xFF64FFDA)),
              label: 'الحفظ و التلاوة',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: Color(0xFF64FFDA)),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
