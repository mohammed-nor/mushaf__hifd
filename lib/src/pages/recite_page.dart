import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';

class RecitePage extends StatefulWidget {
  const RecitePage({super.key});

  @override
  State<RecitePage> createState() => _RecitePageState();
}

class _RecitePageState extends State<RecitePage> {
  int? _currentThomunIndex;
  final Random _random = Random();
  String? _thomunText;

  /// when true we limit picks to the thomuns the user has marked as
  /// learned.  The toggle is exposed in the app bar.
  bool _onlyLearned = false;

  /// Track thomuns marked as revised
  Set<int> _revisedThomuns = {};

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('current_random_thomun_index');
    final onlyLearned = prefs.getBool('recite_only_learned') ?? false;
    final revisedList = prefs.getStringList('revised_thomuns_txt') ?? [];

    if (mounted) {
      setState(() {
        _currentThomunIndex = savedIndex;
        _onlyLearned = onlyLearned;
        _revisedThomuns = revisedList.map((e) => int.tryParse(e) ?? 0).toSet();
      });

      // Load the text for the saved thomun if it exists
      if (_currentThomunIndex != null) {
        try {
          final text = await rootBundle.loadString(
            'lib/thomuns_txt/${kThomunsTxt[_currentThomunIndex!]}',
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
    await prefs.setBool('recite_only_learned', _onlyLearned);
  }

  Future<void> _generateRandomThomun() async {
    List<int> pool = List<int>.generate(kThomunsTxt.length, (i) => i);

    if (_onlyLearned) {
      final prefs = await SharedPreferences.getInstance();
      final learnedList = prefs.getStringList('learned_thomuns_txt') ?? [];
      if (learnedList.isNotEmpty) {
        // map saved indices to their int values
        final filtered = learnedList
            .map(int.tryParse)
            .whereType<int>()
            .where((i) => i >= 0 && i < kThomunsTxt.length)
            .toList();
        if (filtered.isNotEmpty) pool = filtered;
      }
    }

    int randomIndex = _random.nextInt(pool.length);
    int selectedIndex = pool[randomIndex];

    // Load the text content
    try {
      final text = await rootBundle.loadString(
        'lib/thomuns_txt/${kThomunsTxt[selectedIndex]}',
      );
      if (mounted) {
        setState(() {
          _currentThomunIndex = selectedIndex;
          _thomunText = text;
        });
        // Save the index
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('current_random_thomun_index', selectedIndex);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentThomunIndex = selectedIndex;
          _thomunText = null;
        });
        // Save the index even if text failed to load
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('current_random_thomun_index', selectedIndex);
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
            color: const Color(0xFF1DE9B6),
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
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
                _currentThomunIndex != null
                    ? () {
                        final filename = kThomunsTxt[_currentThomunIndex!]
                            .replaceAll('.txt', '');
                        final parts = filename.split('-');
                        if (parts.length == 2) {
                          return 'تلاوة الثمن ${parts[1]} من الحزب ${parts[0]}';
                        }
                        return 'تلاوة: $filename';
                      }()
                    : 'إمتحن حفظك',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: const Color(0xFF64FFDA),
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _onlyLearned = !_onlyLearned;
                      });
                      _saveSavedState();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _onlyLearned
                            ? const Color(0xFF64FFDA).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _onlyLearned
                              ? const Color(0xFF64FFDA)
                              : Colors.white30,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /*                        Icon(
                            _onlyLearned ? Icons.check_box : Icons.check_box_outline_blank,
                            color: _onlyLearned ? const Color(0xFF64FFDA) : Colors.white70,
                            size: 24,
                          ),
                          const SizedBox(width: 8), */
                          Text(
                            'من المحفوظ',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: _onlyLearned
                                      ? const Color(0xFF64FFDA)
                                      : Colors.white70,
                                  fontWeight: _onlyLearned
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
                            padding: const EdgeInsets.all(6.0),
                            child: Card(
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                              color: Colors.white.withAlpha(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: SingleChildScrollView(
                                  child: _buildTextWithGreenBrackets(
                                    _thomunText!
                                        .replaceAll('(', '﴿')
                                        .replaceAll(')', '﴾'),
                                    Theme.of(
                                      context,
                                    ).textTheme.titleLarge!.copyWith(
                                      height: 1.9,
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
                                  color: Colors.white.withAlpha(26),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لم يتم اختيار ثمن بعد',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: Colors.white.withAlpha(128),
                                        height: settings.lineSpacing,
                                      ),
                                ),
                              ],
                            ),
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFF64FFDA), Color(0xFF1DE9B6)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF64FFDA,
                                  ).withAlpha(77), // 0.3 opacity
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
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
                                    _onlyLearned
                                        ? 'اختيار من المحفوظات'
                                        : 'اختيار ثمن عشوائي',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF12121D),
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
                                  ? const Color(0xFF1DE9B6).withAlpha(50)
                                  : Colors.grey.withAlpha(50),
                              border: Border.all(
                                color:
                                    _currentThomunIndex != null &&
                                        _revisedThomuns.contains(
                                          _currentThomunIndex,
                                        )
                                    ? const Color(0xFF1DE9B6)
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
                                  ? const Color(0xFF1DE9B6)
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
}
