import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حفظ القرآن',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Andalus',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF64FFDA), // Teal accent
          secondary: Color(0xFF1DE9B6),
          surface: Color(0xFF1E1E2C), // Deep card background
        ),
        useMaterial3: true,
        scaffoldBackgroundColor:
            Colors.transparent, // Handled by Container gradients
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
  }
}

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

// List of available thomuns based on the directory contents
const List<String> kThomuns = [
  '1-0-1.png',
  '1-0.png',
  '1-1.png',
  '1-2.png',
  '1-3.png',
  '1-4.png',
  '1-5.png',
  '1-6.png',
  '1-7.png',
  '1-8.png',
  '2-1.png',
  '2-2.png',
  '2-3.png',
  '2-4.png',
  '2-5.png',
  '2-6.png',
  '2-7.png',
  '2-8.png',
  '3-1.png',
  '3-2.png',
  '3-3.png',
  '3-4.png',
  '3-5.png',
  '3-6.png',
  '3-7.png',
  '3-8.png',
  '4-1.png',
  '4-2.png',
  '4-3.png',
  '4-4.png',
  '4-5.png',
  '4-6.png',
  '4-7.png',
  '4-8.png',
  '5-1.png',
  '5-2.png',
  '5-3.png',
  '5-4.png',
  '5-5.png',
  '5-6.png',
  '5-7.png',
  '5-8.png',
  '6-1.png',
  '6-2.png',
  '6-3.png',
  '6-4.png',
  '6-5.png',
  '6-6.png',
  '6-7.png',
  '6-8.png',
  '7-1.png',
  '7-2.png',
  '7-3.png',
  '7-4.png',
  '7-5.png',
  '7-6.png',
  '7-7.png',
  '7-8.png',
  '8-1.png',
  '8-2.png',
  '8-3.png',
  '8-4.png',
  '8-5.png',
  '8-6.png',
  '8-7.png',
  '8-8.png',
  '9-1.png',
  '9-2.png',
  '9-3.png',
  '9-4.png',
  '9-5.png',
  '9-6.png',
  '9-7.png',
  '9-8.png',
  '10-1.png',
  '10-2.png',
  '10-3.png',
  '10-4.png',
  '10-5.png',
  '10-6.png',
  '10-7.png',
  '10-8.png',
  '11-1.png',
  '11-2.png',
  '11-3.png',
  '11-4.png',
  '11-5.png',
  '11-6.png',
  '11-7.png',
  '11-8.png',
  '12-1.png',
  '12-2.png',
  '12-3.png',
  '12-4.png',
  '12-5.png',
  '12-6.png',
  '12-7.png',
  '12-8.png',
  '13-1.png',
  '13-2.png',
  '13-3.png',
  '13-4.png',
  '13-5.png',
  '13-6.png',
  '13-7.png',
  '13-8.png',
  '14-1.png',
  '14-2.png',
  '14-3.png',
  '14-4.png',
  '14-5.png',
  '14-6.png',
  '14-7.png',
  '14-8.png',
  '15-1.png',
  '15-2.png',
  '15-3.png',
  '15-4.png',
  '15-5.png',
  '15-6.png',
  '15-7.png',
  '15-8.png',
  '16-1.png',
  '16-2.png',
  '16-3.png',
  '16-4.png',
  '16-5.png',
  '16-6.png',
  '16-7.png',
  '16-8.png',
  '17-1.png',
  '17-2.png',
  '17-3.png',
  '17-4.png',
  '17-5.png',
  '17-6.png',
  '17-7.png',
  '17-8.png',
  '18-1.png',
  '18-2.png',
  '18-3.png',
  '18-4.png',
  '18-5.png',
  '18-6.png',
  '18-7.png',
  '18-8.png',
  '19-1.png',
  '19-2.png',
  '19-3.png',
  '19-4.png',
  '19-5.png',
  '19-6.png',
  '19-7.png',
  '19-8.png',
  '20-1.png',
  '20-2.png',
  '20-3.png',
  '20-4.png',
  '20-5.png',
  '20-6.png',
  '20-7.png',
  '20-8.png',
];

class RecitePage extends StatefulWidget {
  const RecitePage({super.key});

  @override
  State<RecitePage> createState() => _RecitePageState();
}

class _RecitePageState extends State<RecitePage> {
  String? _currentThomun;
  final Random _random = Random();

  void _generateRandomThomun() {
    setState(() {
      int randomIndex = _random.nextInt(kThomuns.length);
      _currentThomun = kThomuns[randomIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232537), Color(0xFF12121D)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _currentThomun != null
                ? 'تلاوة: ${_currentThomun!.replaceAll('.png', '')}'
                : 'تلاوة (عشوائي)',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _currentThomun != null
                    ? Hero(
                        tag: 'thomun_image',
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            'lib/thomuns/$_currentThomun',
                            key: ValueKey<String>(_currentThomun!),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 80,
                              color: Colors.white.withAlpha(26), // 0.1 opacity
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لم يتم اختيار ثمن بعد',
                              style: TextStyle(
                                color: Colors.white.withAlpha(
                                  128,
                                ), // 0.5 opacity
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 32,
                  top: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF64FFDA), Color(0xFF1DE9B6)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF64FFDA,
                        ).withAlpha(77), // 0.3 opacity
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _generateRandomThomun,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shuffle, size: 28, color: Color(0xFF12121D)),
                        SizedBox(width: 12),
                        Text(
                          'اختيار ثمن عشوائي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF12121D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  int _currentIndex = 0;
  late PageController _pageController;
  Set<int> _learnedThomuns = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('current_thomun_index') ?? 0;
    final learnedList = prefs.getStringList('learned_thomuns') ?? [];

    if (mounted) {
      setState(() {
        _currentIndex = savedIndex;
        _learnedThomuns = learnedList.map((e) => int.tryParse(e) ?? 0).toSet();
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      } else {
        _pageController.dispose();
        _pageController = PageController(initialPage: _currentIndex);
      }
    }
  }

  Future<void> _saveCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_thomun_index', _currentIndex);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الصفحة الحالية بنجاح'),
          backgroundColor: Color(0xFF1DE9B6),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleLearnedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_learnedThomuns.contains(_currentIndex)) {
        _learnedThomuns.remove(_currentIndex);
      } else {
        _learnedThomuns.add(_currentIndex);
      }
    });
    await prefs.setStringList(
      'learned_thomuns',
      _learnedThomuns.map((e) => e.toString()).toList(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232537), Color(0xFF12121D)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'إحفظ : ${kThomuns[_currentIndex].replaceAll('.png', '')}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_add, color: Color(0xFF64FFDA)),
              onPressed: _saveCurrentPage,
              tooltip: 'حفظ الصفحة الحالية',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: kThomuns.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        tag: 'thomun_image_$index',
                        child: Image.asset(
                          'lib/thomuns/${kThomuns[index]}',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _toggleLearnedStatus,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _learnedThomuns.contains(_currentIndex)
                              ? const Color(0xFF64FFDA).withAlpha(50)
                              : Colors.grey.withAlpha(50),
                          border: Border.all(
                            color: _learnedThomuns.contains(_currentIndex)
                                ? const Color(0xFF64FFDA)
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _learnedThomuns.contains(_currentIndex)
                              ? 'تم الحفظ'
                              : 'قيد الحفظ',
                          style: TextStyle(
                            color: _learnedThomuns.contains(_currentIndex)
                                ? const Color(0xFF64FFDA)
                                : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentIndex + 1} / ${kThomuns.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64FFDA),
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentIndex.toDouble(),
                        min: 0,
                        max: (kThomuns.length - 1).toDouble(),
                        activeColor: const Color(0xFF64FFDA),
                        inactiveColor: Colors.grey.withAlpha(77),
                        onChanged: (value) {
                          setState(() {
                            _currentIndex = value.toInt();
                          });
                          _pageController.jumpToPage(_currentIndex);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'الإعدادات',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.info_outline,
                  size: 80,
                  color: Color(0xFF64FFDA),
                ),
                const SizedBox(height: 24),
                const Text(
                  'مصحف الحفظ - ورش مثمن',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'تطبيق صمم خصيصاً لمساعدتك على حفظ القرآن الكريم وتسجيل ما تحفظه بسهولة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 24),
                const ListTile(
                  leading: Icon(Icons.copyright, color: Color(0xFF1DE9B6)),
                  title: Text(
                    'حقوق النشر',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  subtitle: Text(
                    'جميع الحقوق محفوظة للمطور محمد نور ©  2026',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                const Spacer(),
                const Text(
                  'الإصدار 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
