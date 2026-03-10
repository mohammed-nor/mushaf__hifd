import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';

/// A companion to [LearnPage] that displays the text versions of the
/// thomuns instead of the image assets.  The UI and persistence logic is
/// intentionally almost identical so the two screens behave the same for the
/// user; the primary difference is how the content is loaded.
class Learn2Page extends StatefulWidget {
  const Learn2Page({super.key});

  @override
  State<Learn2Page> createState() => _Learn2PageState();
}

class _Learn2PageState extends State<Learn2Page> {
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
    final savedIndex = prefs.getInt('current_thomun_txt_index') ?? 0;
    final learnedList = prefs.getStringList('learned_thomuns_txt') ?? [];

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
    await prefs.setInt('current_thomun_txt_index', _currentIndex);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الصفحة الحالية بنجاح'), backgroundColor: Color(0xFF1DE9B6), duration: Duration(seconds: 2)));
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
    await prefs.setStringList('learned_thomuns_txt', _learnedThomuns.map((e) => e.toString()).toList());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232537), Color(0xFF12121D)]),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text('إحفظ نص : ${kThomunsTxt[_currentIndex].replaceAll('.txt', '')}', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: const Color(0xFF64FFDA))),
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
                      itemCount: kThomunsTxt.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder<String>(
                            future: rootBundle.loadString('lib/thomuns_txt/${kThomunsTxt[index]}'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(child: Text('خطأ في تحميل النص'));
                              }
                              return Card(
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.3),
                                color: Colors.white.withAlpha(10),
                                margin: const EdgeInsets.all(3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      snapshot.data ?? '',
                                      textAlign: TextAlign.justify,
                                      style: Theme.of(context).textTheme.titleLarge!.copyWith(height: settings.lineSpacing, fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _toggleLearnedStatus,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _learnedThomuns.contains(_currentIndex) ? const Color(0xFF64FFDA).withAlpha(50) : Colors.grey.withAlpha(50),
                              border: Border.all(color: _learnedThomuns.contains(_currentIndex) ? const Color(0xFF64FFDA) : Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _learnedThomuns.contains(_currentIndex) ? 'تم الحفظ' : 'قيد الحفظ',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium!.copyWith(color: _learnedThomuns.contains(_currentIndex) ? const Color(0xFF64FFDA) : Colors.white70, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentIndex + 1} / ${kThomunsTxt.length}',
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF64FFDA)),
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentIndex.toDouble(),
                            min: 0,
                            max: (kThomunsTxt.length - 1).toDouble(),
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
      },
    );
  }
}
