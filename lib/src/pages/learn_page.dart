import 'package:mushaf_hifd/src/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          backgroundColor: kLightsColor,
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: _buildRichTitle(_currentIndex, settings),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_add, color: kLightsColor),
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
                          padding: const EdgeInsets.all(6.0),
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: .3),
                            color: kLightBackground.withAlpha(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Hero(
                                tag: 'thomun_image_$index',
                                child: Image.asset(
                                  'lib/thomuns/${kThomunsTxt[index]}',
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
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
                                  ? kLightsColor.withAlpha(50)
                                  : Colors.grey.withAlpha(50),
                              border: Border.all(
                                color: _learnedThomuns.contains(_currentIndex)
                                    ? kSecondaryTeal
                                    : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _learnedThomuns.contains(_currentIndex)
                                  ? 'تم الحفظ'
                                  : 'قيد الحفظ',
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(
                                    color:
                                        _learnedThomuns.contains(_currentIndex)
                                        ? kLightsColor
                                        : (settings.isDarkMode
                                              ? kLightBackground
                                              : Colors.black54),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveWidth(
                            context,
                            0.016,
                          ),
                        ),
                        Text(
                          '${_currentIndex + 1} / ${kThomunsTxt.length}',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: kLightsColor,
                              ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentIndex.toDouble(),
                            min: 0,
                            max: (kThomunsTxt.length - 1).toDouble(),
                            activeColor: kLightsColor,
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

  Widget _buildRichTitle(int index, ThemeSettings settings) {
    final filename = kThomunsTxt[index].replaceAll('.txt', '');
    final parts = filename.split('-');

    TextStyle baseStyle = TextStyle(
      color: settings.textColor,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    if (GoogleFonts.asMap().containsKey(settings.fontFamily)) {
      try {
        baseStyle =
            GoogleFonts.getFont(settings.fontFamily, textStyle: baseStyle);
      } catch (e) {
        baseStyle = baseStyle.copyWith(fontFamily: settings.fontFamily);
      }
    } else {
      baseStyle = baseStyle.copyWith(fontFamily: settings.fontFamily);
    }

    if (parts.length == 2) {
      return RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: ' الثمن '),
            TextSpan(
              text: '(${parts[1]})',
              style: const TextStyle(color: kPrimaryTeal),
            ),
            const TextSpan(text: ' الحزب '),
            TextSpan(
              text: '(${parts[0]})',
              style: const TextStyle(color: kPrimaryTeal),
            ),
          ],
        ),
      );
    }
    return Text(
      filename,
      style: baseStyle,
    );
  }
}
