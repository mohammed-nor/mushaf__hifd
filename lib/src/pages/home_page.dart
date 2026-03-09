import 'package:flutter/material.dart';
import 'package:mushaf_hifd/src/pages/recite_page.dart';
import 'package:mushaf_hifd/src/pages/learn_page.dart';
import 'package:mushaf_hifd/src/pages/learn2_page.dart';
import 'package:mushaf_hifd/src/pages/settings_page.dart';

/// The root widget that hosts the bottom navigation bar and switches
/// between the primary screens of the application (recite, image
/// learning, text learning, settings).
class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    RecitePage(),
    LearnPage(),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E2C), Color(0xFF12121D)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77), // 0.3 opacity
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF1E1E2C),
            selectedItemColor: const Color(0xFF64FFDA),
            unselectedItemColor: Colors.grey[500],
            elevation: 0,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'تلاوة'),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'تعلم',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.text_snippet),
                label: 'تعلم نص',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'الإعدادات',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
