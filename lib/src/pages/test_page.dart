import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/services/progress_service.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuizMode { guessNextThumon, identifyThumon }

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  QuizMode _mode = QuizMode.guessNextThumon;
  final Random _rnd = Random();
  List<int> _available = [];

  int? _baseIndex;
  int? _correctIndex;
  List<int> _options = [];
  String _snippet = '';
  int _score = 0; // correct answers in current block of 20
  int _asked = 0; // questions asked in current block
  Map<int, String> _optionSnippets = {};
  List<int> _results = List<int>.filled(
    20,
    0,
  ); // 0=unanswered,1=correct,2=wrong
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _loadAvailable();
  }

  Widget _buildTextWithGreenBrackets(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    int lastIndex = 0;

    final regExp = RegExp(r'[﴿﴾0-9]');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }
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

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(children: spans),
    );
  }

  TextStyle _resolveFont(TextStyle style, ThemeSettings settings) {
    if (GoogleFonts.asMap().containsKey(settings.fontFamily)) {
      try {
        return GoogleFonts.getFont(settings.fontFamily, textStyle: style);
      } catch (e) {
        return style.copyWith(fontFamily: settings.fontFamily);
      }
    }
    return style.copyWith(fontFamily: settings.fontFamily);
  }

  String _buildIdentifySnippet(String text) {
    final normalized = text
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final markerRegExp = RegExp(r'\(\d+\)');
    final matches = markerRegExp.allMatches(normalized).toList();
    if (matches.length < 2) {
      return normalized;
    }

    final segments = <String>[];
    int start = 0;
    for (var i = 0; i < matches.length; i++) {
      final end = matches[i].end;
      segments.add(normalized.substring(start, end).trim());
      start = end;
    }
    if (start < normalized.length) {
      segments.add(normalized.substring(start).trim());
    }

    // Skip the first aya segment to make the quiz harder,
    // then use the next two aya segments only.
    final startIndex = 1;
    if (segments.length <= startIndex + 1) {
      return normalized;
    }

    final endIndex = min(startIndex + 2, segments.length);
    return segments.sublist(startIndex, endIndex).join(' ').trim();
  }

  void _loadAvailable() {
    final learned = progressService.learnedThomuns;
    final revised = progressService.revisedThomuns;
    final intersect = learned.intersection(revised).toList();
    intersect.sort();
    setState(() {
      _available = intersect;
    });
    _nextQuestion();
  }

  Future<void> _nextQuestion() async {
    if (_available.length < 2) {
      setState(() {
        _baseIndex = null;
        _correctIndex = null;
        _options = [];
        _snippet = '';
      });
      return;
    }

    // Pick a base thumon from available
    final base = _available[_rnd.nextInt(_available.length)];

    if (_mode == QuizMode.guessNextThumon) {
      final next = base + 1;
      // ensure next exists in available set
      if (!_available.contains(next)) {
        // try a few times to find a base with a next in set
        final candidates = _available
            .where((i) => _available.contains(i + 1))
            .toList();
        if (candidates.isEmpty) {
          // no valid question
          setState(() {
            _baseIndex = null;
            _correctIndex = null;
            _options = [];
            _snippet = '';
          });
          return;
        }
        final chosen = candidates[_rnd.nextInt(candidates.length)];
        await _prepareGuessNext(chosen);
        return;
      }
      await _prepareGuessNext(base);
    } else {
      await _prepareIdentify(base);
    }
  }

  Future<void> _prepareGuessNext(int base) async {
    final correct = base + 1;
    // options: correct + two random others
    final others = _available.where((i) => i != correct).toList();
    others.shuffle(_rnd);
    final opts = <int>[correct];
    for (var o in others.take(2)) opts.add(o);
    opts.shuffle(_rnd);
    // load a small snippet from base to show context
    final file = kThomunsTxt[base].file;
    String text = '';
    try {
      text = await rootBundle.loadString('lib/thomuns_txt/$file');
    } catch (_) {}

    // load short snippets for options (first 40 chars)
    final Map<int, String> snippets = {};
    for (var o in opts) {
      final ofile = kThomunsTxt[o].file;
      String otext = '';
      try {
        otext = await rootBundle.loadString('lib/thomuns_txt/$ofile');
      } catch (_) {}
      otext = otext.replaceAll('\n', ' ').trim();
      final short = otext.length > 40 ? otext.substring(0, 40) + '...' : otext;
      snippets[o] = short;
    }

    setState(() {
      _baseIndex = base;
      _correctIndex = correct;
      _options = opts;
      _optionSnippets = snippets;
      _snippet = text.trim().split('\n').take(3).join(' ');
    });
  }

  Future<void> _prepareIdentify(int base) async {
    // options: base + two others
    final others = _available.where((i) => i != base).toList();
    others.shuffle(_rnd);
    final opts = <int>[base];
    for (var o in others.take(2)) opts.add(o);
    opts.shuffle(_rnd);

    final file = kThomunsTxt[base].file;
    String text = '';
    try {
      text = await rootBundle.loadString('lib/thomuns_txt/$file');
    } catch (_) {}

    // load short snippets for options (first 40 chars)
    final Map<int, String> snippets = {};
    for (var o in opts) {
      final ofile = kThomunsTxt[o].file;
      String otext = '';
      try {
        otext = await rootBundle.loadString('lib/thomuns_txt/$ofile');
      } catch (_) {}
      otext = otext.replaceAll('\n', ' ').trim();
      final short = otext.length > 40 ? otext.substring(0, 40) + '...' : otext;
      snippets[o] = short;
    }

    setState(() {
      _baseIndex = base;
      _correctIndex = base;
      _options = opts;
      _optionSnippets = snippets;
      _snippet = _buildIdentifySnippet(text);
    });
  }

  void _answer(int selected) async {
    final correct = _correctIndex;
    final isCorrect = selected == correct;
    final slot = _asked; // 0-based slot for this answer
    if (slot >= 0 && slot < 20) {
      _results[slot] = isCorrect ? 1 : 2;
    }
    if (isCorrect) _score++;
    _asked++;
    setState(() {
      _selectedOption = selected;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _selectedOption = null;
    });
    // If we've reached 20 questions, show summary and reset
    if (_asked >= 20) {
      final finalScore = _score;
      final settings = themeSettingsNotifier.value;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: settings.isDarkMode
              ? Colors.grey[900]
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'نتيجة الاختبار',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: settings.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.sp(context, 18) * settings.fontScale,
            ),
          ),
          content: Text(
            textAlign: TextAlign.center,
            'نتيجتك: $finalScore / 20',
            style: TextStyle(
              color: settings.textColor,
              fontSize: ResponsiveUtils.sp(context, 16) * settings.fontScale,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: settings.primaryColor,
                textStyle: TextStyle(
                  fontSize:
                      ResponsiveUtils.sp(context, 15) * settings.fontScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
      // reset
      setState(() {
        _score = 0;
        _asked = 0;
        _results = List<int>.filled(20, 0);
      });
    }
    await _nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Expanded(child: Text('اختبر حفظك')),
            actions: [
              PopupMenuButton<QuizMode>(
                onSelected: (m) async {
                  setState(() => _mode = m);
                  await _nextQuestion();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: QuizMode.guessNextThumon,
                    child: Text('اخمن الثمن التالي'),
                  ),
                  PopupMenuItem(
                    value: QuizMode.identifyThumon,
                    child: Text('عرف الثمن من المقطع'),
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: settings.backgroundGradient,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _available.length < 2
                  ? Text(
                      'لا توجد أثمان كافية للمراجعة والاختبار. علّم وراجع بعض الأثمان أولاً.',
                      style: TextStyle(
                        color: settings.textColor,
                        fontSize:
                            ResponsiveUtils.sp(context, 16) *
                            settings.fontScale,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_baseIndex != null) ...[
                          Expanded(
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
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _mode == QuizMode.guessNextThumon
                                          ? 'المقطع المعروض (اختر الثمن التالي)'
                                          : 'مقطع - عرف أي ثمن هذا',
                                      style: TextStyle(
                                        color: settings.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            ResponsiveUtils.sp(context, 16) *
                                            settings.fontScale,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    // Render snippet like Learn2Page (with green brackets/highlighted digits)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: double.infinity,
                                        ),
                                        child: SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: _buildTextWithGreenBrackets(
                                            (_snippet
                                                .replaceAll('(', '﴿')
                                                .replaceAll(')', '﴾')),
                                            _resolveFont(
                                              Theme.of(
                                                context,
                                              ).textTheme.titleLarge!.copyWith(
                                                color: settings.textColor,
                                                height: settings.lineSpacing,
                                                fontWeight: FontWeight.normal,
                                                fontSize:
                                                    ResponsiveUtils.sp(
                                                      context,
                                                      18,
                                                    ) *
                                                    settings.fontScale,
                                              ),
                                              settings,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._options.map((opt) {
                            final label =
                                _optionSnippets[opt] ??
                                'الحزب ${kThomunsTxt[opt].file.replaceAll('.txt', '')}';
                            final isSelected = _selectedOption != null;
                            final isCorrect = opt == _correctIndex;
                            final isChosenWrong =
                                _selectedOption == opt && !isCorrect;
                            final isCorrectShown = isSelected && isCorrect;
                            final bgColor = isChosenWrong
                                ? Colors.red.withOpacity(0.18)
                                : isCorrectShown
                                ? Colors.green.withOpacity(0.24)
                                : Colors.grey.withAlpha(0);
                            final borderColor = isChosenWrong
                                ? Colors.red
                                : isCorrectShown
                                ? Colors.green
                                : Colors.grey;
                            final textColor = isChosenWrong
                                ? Colors.red.shade700
                                : isCorrectShown
                                ? Colors.green.shade700
                                : settings.textColor;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _selectedOption == null
                                    ? () => _answer(opt)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              ResponsiveUtils.sp(context, 16) *
                                              settings.fontScale,
                                        ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 12),
                          // 20 indicators row
                          Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 6,
                                runSpacing: 6,
                                children: List.generate(20, (i) {
                                  Color dotColor;
                                  if (_results[i] == 1) {
                                    dotColor = Colors.green; // correct
                                  } else if (_results[i] == 2) {
                                    dotColor = Colors.red; // wrong
                                  } else {
                                    dotColor = settings.textColor.withAlpha(
                                      100,
                                    ); // unanswered
                                  }
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'النسبة: ${((_score / 20) * 100).round()}%  ($_score/20)',
                                style: TextStyle(
                                  color: settings.textColor,
                                  fontSize:
                                      ResponsiveUtils.sp(context, 14) *
                                      settings.fontScale,
                                ),
                              ),
                            ],
                          ),
                        ] else
                          const SizedBox.shrink(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
