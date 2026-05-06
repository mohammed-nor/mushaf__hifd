import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:mushaf_hifd/src/services/notification_service.dart';
import 'package:mushaf_hifd/src/services/progress_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mushaf_hifd/src/pages/thumon_search_delegate.dart';

/// A companion to [LearnPage] that displays the text versions of the
/// thomuns instead of the image assets.  The UI and persistence logic is
/// intentionally almost identical so the two screens behave the same for the
/// user; the primary difference is how the content is loaded.
class Learn2Page extends StatefulWidget {
  final int? initialIndex;
  const Learn2Page({super.key, this.initialIndex});

  @override
  State<Learn2Page> createState() => _Learn2PageState();
}

class _Learn2PageState extends State<Learn2Page> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('current_thomun_txt_index') ?? 0;

    if (mounted) {
      setState(() {
        if (widget.initialIndex == null) {
          _currentIndex = savedIndex;
        }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ الصفحة الحالية بنجاح'),
          backgroundColor: themeSettingsNotifier.value.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleLearnedStatus() async {
    await progressService.toggleLearned(_currentIndex);
  }

  Future<void> _toggleRevisedStatus() async {
    final notificationService = NotificationService.instance;
    await progressService.toggleRevised(_currentIndex);

    // Schedule or cancel notification based on revision status
    if (progressService.revisedThomuns.contains(_currentIndex)) {
      await notificationService.scheduleRevisionReminder(_currentIndex);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم جدولة تذكير المراجعة 📬'),
            backgroundColor: themeSettingsNotifier.value.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await notificationService.cancelReminder(_currentIndex);
    }
  }

  Widget _buildTextWithGreenBrackets(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    int lastIndex = 0;

    final regExp = RegExp(r'[﴿﴾0-9]');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      // Add text before match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }
      // Add colored bracket
      spans.add(
        TextSpan(
          text: match.group(0),
          style: baseStyle.copyWith(
            color: themeSettingsNotifier.value.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(children: spans),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showSearch(BuildContext context, ThemeSettings settings) async {
    final result = await showSearch<int?>(
      context: context,
      delegate: ThumonSearchDelegate(
        settings: settings,
        filenames: kThomunsTxt,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentIndex = result;
      });
      _pageController.jumpToPage(_currentIndex);
    }
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
              //toolbarHeight: 70,
              leading: IconButton(
                icon: Icon(Icons.search, color: settings.primaryColor),
                onPressed: () => _showSearch(context, settings),
                tooltip: 'بحث في الأثمان',
              ),
              title: _buildRichTitle(_currentIndex, settings),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.bookmark_add, color: settings.primaryColor),
                  onPressed: _saveCurrentPage,
                  tooltip: 'حفظ الصفحة الحالية',
                ),
              ],
            ),
            body: SafeArea(
              child: ListenableBuilder(
                listenable: progressService,
                builder: (context, _) {
                  return Column(
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
                              padding: const EdgeInsets.all(4.0),
                              child: FutureBuilder<String>(
                                future: rootBundle.loadString(
                                  'lib/thomuns_txt/${kThomunsTxt[index].file}',
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text('خطأ في تحميل النص'),
                                    );
                                  }
                                  return Card(
                                    elevation: 2,
                                    //shadowColor: Colors.black.withValues(alpha: 0.3),
                                    color: kLightBackground.withAlpha(0),
                                    margin: const EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: settings.isDarkMode
                                            ? kLightBackground.withAlpha(20)
                                            : Colors.black.withAlpha(10),
                                        width: 2,
                                      ),
                                    ),

                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: SingleChildScrollView(
                                        child: _buildTextWithGreenBrackets(
                                          (snapshot.data ?? '')
                                              .replaceAll('(', '﴿')
                                              .replaceAll(')', '﴾'),
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge!.copyWith(
                                            color: settings.textColor,
                                            height: settings.lineSpacing,
                                            fontWeight: FontWeight.normal,
                                          ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
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
                                  color:
                                      progressService.learnedThomuns.contains(
                                        _currentIndex,
                                      )
                                      ? settings.primaryColor.withAlpha(10)
                                      : Colors.grey.withAlpha(0),
                                  border: Border.all(
                                    color:
                                        progressService.learnedThomuns.contains(
                                          _currentIndex,
                                        )
                                        ? settings.primaryColor
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  progressService.learnedThomuns.contains(
                                        _currentIndex,
                                      )
                                      ? 'تم الحفظ'
                                      : 'قيد الحفظ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color:
                                            progressService.learnedThomuns
                                                .contains(_currentIndex)
                                            ? settings.primaryColor
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
                                    color: settings.primaryColor,
                                  ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _currentIndex.toDouble(),
                                min: 0,
                                max: (kThomunsTxt.length - 1).toDouble(),
                                activeColor: settings.primaryColor,
                                inactiveColor: Colors.grey.withAlpha(77),
                                onChanged: (value) {
                                  setState(() {
                                    _currentIndex = value.toInt();
                                  });
                                  _pageController.jumpToPage(_currentIndex);
                                },
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveUtils.getResponsiveWidth(
                                context,
                                0.016,
                              ),
                            ),
                            if (progressService.revisedThomuns.contains(
                              _currentIndex,
                            ))
                              InkWell(
                                onTap: _toggleRevisedStatus,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: settings.primaryColor.withAlpha(50),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'مراجع',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: settings.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              )
                            else
                              InkWell(
                                onTap: _toggleRevisedStatus,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(0),
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'لم يراجع',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: settings.isDarkMode
                                              ? kLightBackground
                                              : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRichTitle(int index, ThemeSettings settings) {
    final entry = kThomunsTxt[index];
    final filename = entry.file.replaceAll('.txt', '');
    final parts = filename.split('-');

    TextStyle baseStyle = TextStyle(
      color: settings.textColor,
      fontWeight: FontWeight.w600,
      fontSize: ResponsiveUtils.sp(context, 14) * settings.fontScale,
    );

    TextStyle surahStyle = TextStyle(
      color: settings.textColor.withAlpha(180),
      fontWeight: FontWeight.w400,
      fontSize: ResponsiveUtils.sp(context, 12) * settings.fontScale,
    );

    if (GoogleFonts.asMap().containsKey(settings.fontFamily)) {
      try {
        baseStyle = GoogleFonts.getFont(
          settings.fontFamily,
          textStyle: baseStyle,
        );
        surahStyle = GoogleFonts.getFont(
          settings.fontFamily,
          textStyle: surahStyle,
        );
      } catch (e) {
        baseStyle = baseStyle.copyWith(fontFamily: settings.fontFamily);
        surahStyle = surahStyle.copyWith(fontFamily: settings.fontFamily);
      }
    } else {
      baseStyle = baseStyle.copyWith(fontFamily: settings.fontFamily);
      surahStyle = surahStyle.copyWith(fontFamily: settings.fontFamily);
    }

    Widget titleContent;
    if (parts.length == 2) {
      titleContent = RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: ' الثمن '),
            TextSpan(
              text: '(${parts[1]})',
              style: TextStyle(color: settings.primaryColor),
            ),
            const TextSpan(text: ' الحزب '),
            TextSpan(
              text: '(${parts[0]})',
              style: TextStyle(color: settings.primaryColor),
            ),
          ],
        ),
      );
    } else {
      titleContent = Text(filename, style: baseStyle);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleContent,
          Text(entry.surah, style: surahStyle),
        ],
      ),
    );
  }
}
