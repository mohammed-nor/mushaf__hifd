import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:google_fonts/google_fonts.dart';

enum ReciteFilter { all, learned, notLearned }

class RecitePage extends StatefulWidget {
  const RecitePage({super.key});

  @override
  State<RecitePage> createState() => _RecitePageState();
}

class _RecitePageState extends State<RecitePage> {
  int? _currentThomunIndex;
  final Random _random = Random();
  String? _thomunText;

  /// Filter mode for picking random thomuns
  ReciteFilter _filterMode = ReciteFilter.all;

  /// Track thomuns marked as revised
  Set<int> _revisedThomuns = {};

  /// Time when the current thomun was selected
  DateTime? _selectionTime;
  Timer? _timer;
  String _elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_selectionTime != null) {
        final now = DateTime.now();
        final diff = now.difference(_selectionTime!);
        final d = diff.inDays;
        final h = diff.inHours.remainder(24);
        final m = diff.inMinutes.remainder(60);
        final s = diff.inSeconds.remainder(60);

        String timeStr = '';
        if (d > 0) timeStr += '$dي ';
        if (h > 0 || d > 0) timeStr += '${h.toString().padLeft(2, '0')}:';
        timeStr +=
            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

        if (mounted && _elapsedTime != timeStr) {
          setState(() {
            _elapsedTime = timeStr;
          });
        }
      }
    });
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('current_random_thomun_index');
    final filterIndex = prefs.getInt('recite_filter_mode') ?? 0;
    final revisedList = prefs.getStringList('revised_thomuns_txt') ?? [];
    final selectionTimeMillis = prefs.getInt(
      'current_thomun_selection_time_millis',
    );

    if (mounted) {
      setState(() {
        _currentThomunIndex = savedIndex;
        _filterMode = ReciteFilter.values[filterIndex];
        _revisedThomuns = revisedList.map((e) => int.tryParse(e) ?? 0).toSet();
        if (selectionTimeMillis != null) {
          _selectionTime = DateTime.fromMillisecondsSinceEpoch(
            selectionTimeMillis,
          );
        } else if (_currentThomunIndex != null) {
          // Fallback: if we have a thomun but no selection time, set it to now
          _selectionTime = DateTime.now();
        }
      });

      // Load the text for the saved thomun if it exists
      if (_currentThomunIndex != null) {
        try {
          final text = await rootBundle.loadString(
            'lib/thomuns_txt/${kThomunsTxt[_currentThomunIndex!].file}',
          );

          if (mounted) {
            setState(() {
              _thomunText = text;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _thomunText = null;
            });
          }
        }
      }
    }
  }

  Future<void> _toggleRevisedStatus() async {
    if (_currentThomunIndex == null) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_revisedThomuns.contains(_currentThomunIndex)) {
        _revisedThomuns.remove(_currentThomunIndex);
      } else {
        _revisedThomuns.add(_currentThomunIndex!);
      }
    });
    await prefs.setStringList(
      'revised_thomuns_txt',
      _revisedThomuns.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('recite_filter_mode', _filterMode.index);
  }

  Future<void> _generateRandomThomun() async {
    List<int> pool = List<int>.generate(kThomunsTxt.length, (i) => i);

    if (_filterMode != ReciteFilter.all) {
      final prefs = await SharedPreferences.getInstance();
      final learnedList = prefs.getStringList('learned_thomuns_txt') ?? [];
      final learnedIndices = learnedList
          .map(int.tryParse)
          .whereType<int>()
          .where((i) => i >= 0 && i < kThomunsTxt.length)
          .toSet();

      if (_filterMode == ReciteFilter.learned) {
        if (learnedIndices.isNotEmpty) {
          pool = learnedIndices.toList();
        }
      } else if (_filterMode == ReciteFilter.notLearned) {
        final notLearned = pool
            .where((i) => !learnedIndices.contains(i))
            .toList();
        if (notLearned.isNotEmpty) {
          pool = notLearned;
        }
      }
    }

    int randomIndex = _random.nextInt(pool.length);
    int selectedIndex = pool[randomIndex];

    // Load the text content
    try {
      final text = await rootBundle.loadString(
        'lib/thomuns_txt/${kThomunsTxt[selectedIndex].file}',
      );

      if (mounted) {
        setState(() {
          _currentThomunIndex = selectedIndex;
          _thomunText = text;
        });
        // Save the index
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        await prefs.setInt('current_random_thomun_index', selectedIndex);
        await prefs.setInt(
          'current_thomun_selection_time_millis',
          now.millisecondsSinceEpoch,
        );
        if (mounted) {
          setState(() {
            _selectionTime = now;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentThomunIndex = selectedIndex;
          _thomunText = null;
        });
        // Save the index even if text failed to load
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        await prefs.setInt('current_random_thomun_index', selectedIndex);
        await prefs.setInt(
          'current_thomun_selection_time_millis',
          now.millisecondsSinceEpoch,
        );
        if (mounted) {
          setState(() {
            _selectionTime = now;
          });
        }
      }
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

  Widget _buildThomunHintContainer(
    String text,
    String label,
    ThemeSettings settings, {
    bool isRevised = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: isRevised
              ? settings.primaryColor.withAlpha(80)
              : kLightBackground.withAlpha(8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isRevised
                ? settings.primaryColor
                : settings.primaryColor.withAlpha(100),
            width: isRevised ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: settings.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5,
                  color: settings.isDarkMode
                      ? kLightBackground
                      : Colors.black54,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getThomunStartText(int index) async {
    try {
      final text = await rootBundle.loadString(
        'lib/thomuns_txt/${kThomunsTxt[index].file}',
      );

      // Get first 50 characters or until first line break
      final lines = text.split('\n');
      final firstLine = lines.first.trim();
      if (firstLine.length > 60) {
        return '${firstLine.substring(0, 60)}...';
      }
      return firstLine;
    } catch (e) {
      return '';
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
              leading: _selectionTime == null
                  ? null
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: settings.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: settings.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _elapsedTime,
                          style: TextStyle(
                            color: settings.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
              leadingWidth: 80,
              title: _currentThomunIndex == null
                  ? Text(
                      'إمتحن حفظك',
                      style: TextStyle(color: settings.textColor),
                    )
                  : _buildRichTitle(_currentThomunIndex!, settings, 'تلاوة'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // Toggle between: all -> learned -> notLearned -> all
                        int nextIndex =
                            (_filterMode.index + 1) %
                            ReciteFilter.values.length;
                        _filterMode = ReciteFilter.values[nextIndex];
                      });
                      _saveSavedState();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _filterMode != ReciteFilter.all
                            ? settings.primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _filterMode != ReciteFilter.all
                              ? settings.primaryColor
                              : (settings.isDarkMode
                                    ? kLightBackground.withValues(alpha: 0.5)
                                    : Colors.black26),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filterMode == ReciteFilter.all
                                ? 'الكل'
                                : (_filterMode == ReciteFilter.learned
                                      ? 'من المحفوظ'
                                      : 'غير المحفوظ'),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: _filterMode != ReciteFilter.all
                                      ? settings.primaryColor
                                      : (settings.isDarkMode
                                            ? kLightBackground
                                            : Colors.black54),
                                  fontWeight: _filterMode != ReciteFilter.all
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: _currentThomunIndex != null && _thomunText != null
                        ? Padding(
                            padding: const EdgeInsets.all(0),
                            child: Card(
                              elevation: 8,
                              //shadowColor: Colors.black.withValues(alpha: 0.3),
                              color: kLightBackground.withAlpha(0),
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
                                padding: const EdgeInsets.all(4),
                                child: SingleChildScrollView(
                                  child: _buildTextWithGreenBrackets(
                                    _thomunText!
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
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_stories,
                                  size: 80,
                                  color: settings.textColor.withAlpha(26),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لم يتم اختيار ثمن بعد',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: settings.textColor.withAlpha(
                                          128,
                                        ),
                                        height: settings.lineSpacing,
                                      ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (_currentThomunIndex != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Row(
                        children: [
                          if (_currentThomunIndex! > 0)
                            FutureBuilder<String>(
                              future: _getThomunStartText(
                                _currentThomunIndex! - 1,
                              ),
                              builder: (context, snapshot) {
                                return _buildThomunHintContainer(
                                  snapshot.data ?? '',
                                  'السابق',
                                  settings,
                                  isRevised: _revisedThomuns.contains(
                                    _currentThomunIndex! - 1,
                                  ),
                                );
                              },
                            ),
                          if (_currentThomunIndex! > 0 &&
                              _currentThomunIndex! < kThomunsTxt.length - 1)
                            const SizedBox(width: 4),
                          if (_currentThomunIndex! < kThomunsTxt.length - 1)
                            FutureBuilder<String>(
                              future: _getThomunStartText(
                                _currentThomunIndex! + 1,
                              ),
                              builder: (context, snapshot) {
                                return _buildThomunHintContainer(
                                  snapshot.data ?? '',
                                  'التالي',
                                  settings,
                                  isRevised: _revisedThomuns.contains(
                                    _currentThomunIndex! + 1,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                      bottom: 6,
                      top: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  settings.primaryColor,
                                  settings.primaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: settings.primaryColor.withAlpha(77),
                                  blurRadius: 3, // 0.3 opacity
                                  //offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _generateRandomThomun,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _filterMode == ReciteFilter.all
                                        ? 'اختيار ثمن عشوائي'
                                        : (_filterMode == ReciteFilter.learned
                                              ? 'اختيار من المحفوظات'
                                              : 'اختيار من غير المحفوظ'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kDarkBackgroundVariant,
                                          height: settings.lineSpacing,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Center(
                          child: /*Container(
                            decoration: BoxDecoration(
                              color:
                                  _currentThomunIndex != null &&
                                      _revisedThomuns.contains(
                                        _currentThomunIndex,
                                      )
                                  ? Theme.of(context).primaryColor.withAlpha(50)
                                  : Colors.grey.withAlpha(50),
                              border: Border.all(
                                color:
                                    _currentThomunIndex != null &&
                                        _revisedThomuns.contains(
                                          _currentThomunIndex,
                                        )
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                //width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: */ ElevatedButton(
                            onPressed: _currentThomunIndex != null
                                ? _toggleRevisedStatus
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Icon(
                              _currentThomunIndex != null &&
                                      _revisedThomuns.contains(
                                        _currentThomunIndex,
                                      )
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color:
                                  _currentThomunIndex != null &&
                                      _revisedThomuns.contains(
                                        _currentThomunIndex,
                                      )
                                  ? settings.primaryColor
                                  : Colors.grey,
                              size: 35,
                            ),
                          ),
                        ),
                        /* ), */
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

  Widget _buildRichTitle(int index, ThemeSettings settings, String prefix) {
    final entry = kThomunsTxt[index];
    final filename = entry.file.replaceAll('.txt', '');
    final parts = filename.split('-');

    TextStyle baseStyle = TextStyle(
      color: settings.textColor,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    TextStyle surahStyle = TextStyle(
      color: settings.textColor.withAlpha(180),
      fontWeight: FontWeight.w400,
      fontSize: 13,
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

    Widget mainTitle;
    if (parts.length == 2) {
      mainTitle = RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: '$prefix الثمن '),
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
      mainTitle = Text(filename, style: baseStyle);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mainTitle,
        Text(entry.surah, style: surahStyle),
      ],
    );
  }
}

