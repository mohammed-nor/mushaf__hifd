import 'package:flutter/material.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/pages/recite_page.dart';
import 'package:mushaf_hifd/src/pages/learn2_page.dart';
import 'package:mushaf_hifd/src/pages/settings_page.dart';
import 'package:mushaf_hifd/src/pages/test_page.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

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
    Learn2Page(),
    RecitePage(),
    TestPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRatingDialog();
    });
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تقييم التطبيق', textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'فضلاً، قيم التطبيق بـ 5 نجوم لدعمنا في الاستمرار.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'جزاك الله خيراً وبارك فيك وجعله في ميزان حسناتك.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  await inAppReview.requestReview();
                } else {
                  final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.norit.mushaf_hifd');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    await inAppReview.openStoreListing();
                  }
                }
              },
              child: const Text('تقييم الآن ⭐'),
            ),
          ],
        );
      },
    );
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
              colors: settings.backgroundGradient,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              height: 65,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.black.withValues(alpha: 0),
              surfaceTintColor: settings.primaryColor.withValues(alpha: 0.1),
              indicatorColor: settings.primaryColor.withValues(alpha: 0.2),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.text_snippet_outlined),
                  selectedIcon: Icon(
                    Icons.text_snippet,
                    color: settings.primaryColor,
                  ),
                  label: 'الحفظ و التلاوة',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.history_edu),
                  selectedIcon: Icon(
                    Icons.history_edu,
                    color: settings.primaryColor,
                  ),
                  label: 'الإستظهار',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.quiz),
                  selectedIcon: Icon(Icons.quiz, color: settings.primaryColor),
                  label: 'الاختبار',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: Icon(
                    Icons.settings,
                    color: settings.primaryColor,
                  ),
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
