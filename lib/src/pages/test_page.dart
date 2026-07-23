import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/services/progress_service.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuizMode { guessNextThumon, identifyThumon, classifyHizb, orderHizb }

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
  Map<int, String> _optionLabels = {};
  int? _currentHizb;
  List<int> _hizbThomuns = [];
  List<int> _shuffledHizbThomuns = [];
  int _nextThumunPosition = 0;
  Set<int> _completedHizbThomuns = {};
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

  int _hizbFromIndex(int index) {
    final parts = kThomunsTxt[index].file.split('-');
    return int.tryParse(parts.first) ?? 0;
  }

  String _hizbLabel(int hizb) => 'الحزب $hizb';

  String _thumunTileLabel(int index) {
    final parts = kThomunsTxt[index].file.split('-');
    final thumunNumber = parts.length > 1
        ? parts[1].replaceAll('.txt', '')
        : '${index + 1}';
    return 'الثمن $thumunNumber';
  }

  String _buildOrderSnippet(String firstText, String lastText) {
    final first = firstText
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final last = lastText
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final firstPart = first.length > 60
        ? '${first.substring(0, 60)}...'
        : first;
    final lastPart = last.length > 60
        ? '...${last.substring(last.length - 60)}'
        : last;
    return '$firstPart\n...\n$lastPart';
  }

  List<int> _learnedHizbs() {
    return progressService.learnedThomuns.map(_hizbFromIndex).toSet().toList()
      ..sort();
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
    // then use the next three aya segments for a longer prompt.
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
    if (_mode == QuizMode.orderHizb) {
      final learnedHizbs = _learnedHizbs();
      if (learnedHizbs.isEmpty) {
        setState(() {
          _currentHizb = null;
          _baseIndex = null;
          _correctIndex = null;
          _options = [];
          _snippet = '';
        });
        return;
      }
      await _prepareOrderHizb(learnedHizbs[_rnd.nextInt(learnedHizbs.length)]);
      return;
    }

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
    } else if (_mode == QuizMode.identifyThumon) {
      await _prepareIdentify(base);
    } else {
      await _prepareClassifyHizb(base);
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
      text = await rootBundle.loadString('lib/warsh_thomuns_txt/$file');
    } catch (_) {}

    // load short snippets for options (first 80 chars)
    final Map<int, String> snippets = {};
    for (var o in opts) {
      final ofile = kThomunsTxt[o].file;
      String otext = '';
      try {
        otext = await rootBundle.loadString('lib/warsh_thomuns_txt/$ofile');
      } catch (_) {}
      otext = otext.replaceAll('\n', ' ').trim();
      final short = otext.length > 55 ? otext.substring(0, 55) + '...' : otext;
      snippets[o] = short;
    }

    setState(() {
      _baseIndex = base;
      _correctIndex = correct;
      _options = opts;
      _optionSnippets = snippets;
      _optionLabels = Map.from(snippets);
      _snippet = text.trim().split('\n').take(5).join(' ');
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
      text = await rootBundle.loadString('lib/warsh_thomuns_txt/$file');
    } catch (_) {}

    // load short snippets for options (first 80 chars)
    final Map<int, String> snippets = {};
    for (var o in opts) {
      final ofile = kThomunsTxt[o].file;
      String otext = '';
      try {
        otext = await rootBundle.loadString('lib/warsh_thomuns_txt/$ofile');
      } catch (_) {}
      otext = otext.replaceAll('\n', ' ').trim();
      final short = otext.length > 80 ? otext.substring(0, 80) + '...' : otext;
      snippets[o] = short;
    }

    setState(() {
      _baseIndex = base;
      _correctIndex = base;
      _options = opts;
      _optionSnippets = snippets;
      _optionLabels = Map.from(snippets);
      _snippet = _buildIdentifySnippet(text);
    });
  }

  Future<void> _prepareClassifyHizb(int base) async {
    final correctHizb = _hizbFromIndex(base);
    final learnedHizbs = _learnedHizbs();
    if (learnedHizbs.length < 3) {
      setState(() {
        _baseIndex = null;
        _correctIndex = null;
        _options = [];
        _snippet = '';
        _optionLabels = {};
        _optionSnippets = {};
      });
      return;
    }

    final otherHizbs = learnedHizbs.where((h) => h != correctHizb).toList();
    otherHizbs.shuffle(_rnd);
    final opts = <int>[correctHizb];
    opts.addAll(otherHizbs.take(2));
    opts.shuffle(_rnd);

    final file = kThomunsTxt[base].file;
    String text = '';
    try {
      text = await rootBundle.loadString('lib/warsh_thomuns_txt/$file');
    } catch (_) {}

    final labels = {for (var hizb in opts) hizb: _hizbLabel(hizb)};
    setState(() {
      _baseIndex = base;
      _correctIndex = correctHizb;
      _options = opts;
      _optionLabels = labels;
      _optionSnippets = {};
      _snippet = _buildIdentifySnippet(text);
    });
  }

  Future<void> _prepareOrderHizb(int hizb) async {
    _currentHizb = hizb;
    _completedHizbThomuns.clear();
    _nextThumunPosition = 0;

    final allThomuns = <int>[];
    for (var i = 0; i < kThomunsTxt.length; i++) {
      if (_hizbFromIndex(i) == hizb) {
        allThomuns.add(i);
      }
    }
    allThomuns.sort();
    _hizbThomuns = allThomuns;
    _shuffledHizbThomuns = List<int>.from(allThomuns)..shuffle(_rnd);

    if (_shuffledHizbThomuns.isEmpty) {
      setState(() {
        _currentHizb = null;
        _baseIndex = null;
        _correctIndex = null;
        _options = [];
        _snippet = '';
      });
      return;
    }

    final firstFile = kThomunsTxt[_hizbThomuns.first].file;
    final lastFile = kThomunsTxt[_hizbThomuns.last].file;
    String firstText = '';
    String lastText = '';
    try {
      firstText = await rootBundle.loadString(
        'lib/warsh_thomuns_txt/$firstFile',
      );
    } catch (_) {}
    try {
      lastText = await rootBundle.loadString('lib/warsh_thomuns_txt/$lastFile');
    } catch (_) {}

    final labels = {
      for (var idx in _shuffledHizbThomuns) idx: _thumunTileLabel(idx),
    };

    final snippets = <int, String>{};
    for (var idx in _shuffledHizbThomuns) {
      final file = kThomunsTxt[idx].file;
      String text = '';
      try {
        text = await rootBundle.loadString('lib/warsh_thomuns_txt/$file');
      } catch (_) {}
      text = text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      snippets[idx] = text.length > 95 ? '${text.substring(0, 95)}...' : text;
    }

    setState(() {
      _baseIndex = _hizbThomuns.first;
      _correctIndex = _hizbThomuns[_nextThumunPosition];
      _options = _shuffledHizbThomuns;
      _optionLabels = labels;
      _optionSnippets = snippets;
      _snippet = _buildOrderSnippet(firstText, lastText);
    });
  }

  void _answer(int selected) async {
    if (_mode == QuizMode.orderHizb) {
      await _answerOrderHizb(selected);
      return;
    }

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

  Future<void> _answerOrderHizb(int selected) async {
    if (_currentHizb == null || _nextThumunPosition >= _hizbThomuns.length) {
      return;
    }

    final expected = _hizbThomuns[_nextThumunPosition];
    final isCorrect = selected == expected;
    setState(() {
      _selectedOption = selected;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (isCorrect) {
      _completedHizbThomuns.add(selected);
      _nextThumunPosition++;
    }

    setState(() {
      _selectedOption = null;
    });

    if (_nextThumunPosition >= _hizbThomuns.length) {
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
            'اختبار الحزب ${_currentHizb ?? ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: settings.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.sp(context, 18) * settings.fontScale,
            ),
          ),
          content: Text(
            textAlign: TextAlign.center,
            'أكملت ترتيب الحزب ${_currentHizb ?? ''} بنجاح.',
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
      await _nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        final learnedHizbs = _learnedHizbs();
        final isClassifyBlocked =
            _mode == QuizMode.classifyHizb && learnedHizbs.length < 3;
        final isOrderBlocked =
            _mode == QuizMode.orderHizb && learnedHizbs.isEmpty;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _mode == QuizMode.guessNextThumon
                  ? 'تعرف على الثمن التالي'
                  : _mode == QuizMode.identifyThumon
                  ? 'تعرف أي ثمن هذا'
                  : _mode == QuizMode.classifyHizb
                  ? 'حدد الحزب من المقطع'
                  : 'رتب أثمان الحزب',
              style: TextStyle(
                color: settings.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.sp(context, 16) * settings.fontScale,
              ),
              textAlign: TextAlign.center,
            ),
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
                  PopupMenuItem(
                    value: QuizMode.classifyHizb,
                    child: Text('حدد الحزب من المقطع'),
                  ),
                  PopupMenuItem(
                    value: QuizMode.orderHizb,
                    child: Text('رتب أثمان الحزب'),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child:
                    _available.length < 2 || isClassifyBlocked || isOrderBlocked
                    ? Text(
                        isClassifyBlocked
                            ? 'لتشغيل اختبار تحديد الحزب، علّم ثلاثة أحزاب أو أكثر أولاً.'
                            : isOrderBlocked
                            ? 'لتشغيل اختبار ترتيب الحزب، علّم حزباً واحداً على الأقل.'
                            : 'لا توجد أثمان كافية للمراجعة والاختبار. علّم وراجع بعض الأثمان أولاً.',
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
                                  child: _mode == QuizMode.orderHizb
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'رتب أثمان الحزب ${_currentHizb ?? ''}',
                                              textAlign: TextAlign.center,
                                              style: _resolveFont(
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(
                                                      color: settings.textColor,
                                                      height:
                                                          settings.lineSpacing,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            const SizedBox(height: 12),
                                            Text(
                                              'انقر على الأثمان بالترتيب الصحيح.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: settings.textColor,
                                                fontSize:
                                                    ResponsiveUtils.sp(
                                                      context,
                                                      14,
                                                    ) *
                                                    settings.fontScale,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ConstrainedBox(
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
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(
                                                      color: settings.textColor,
                                                      height:
                                                          settings.lineSpacing,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_mode == QuizMode.orderHizb) ...[
                              Text(
                                'انقر على الأثمان بالترتيب الصحيح.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: settings.textColor,
                                  fontSize:
                                      ResponsiveUtils.sp(context, 14) *
                                      settings.fontScale,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 2,
                                runSpacing: 2,
                                children: _options.map((opt) {
                                  final title =
                                      _optionSnippets[opt] ??
                                      _optionLabels[opt] ??
                                      _thumunTileLabel(opt);
                                  final isSelected = _selectedOption != null;
                                  final isCompleted = _completedHizbThomuns
                                      .contains(opt);
                                  final isCorrect = opt == _correctIndex;
                                  final isChosenWrong =
                                      _selectedOption == opt && !isCorrect;
                                  final isCorrectShown =
                                      isSelected && isCorrect;
                                  final bgColor = isCompleted
                                      ? Colors.green.withOpacity(0.24)
                                      : isChosenWrong
                                      ? Colors.red.withOpacity(0.18)
                                      : isCorrectShown
                                      ? Colors.green.withOpacity(0.24)
                                      : Colors.grey.withAlpha(0);
                                  final borderColor = isCompleted
                                      ? Colors.green
                                      : isChosenWrong
                                      ? Colors.red
                                      : isCorrectShown
                                      ? Colors.green
                                      : Colors.grey;
                                  final textColor = isCompleted
                                      ? Colors.green.shade700
                                      : isChosenWrong
                                      ? Colors.red.shade700
                                      : isCorrectShown
                                      ? Colors.green.shade700
                                      : settings.textColor;
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap:
                                          _selectedOption == null &&
                                              !isCompleted
                                          ? () => _answer(opt)
                                          : null,
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                        ),
                                        child: Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: textColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ResponsiveUtils.sp(
                                                      context,
                                                      14,
                                                    ) *
                                                    settings.fontScale,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ] else ...[
                              ..._options.map((opt) {
                                final label =
                                    _optionLabels[opt] ??
                                    _optionSnippets[opt] ??
                                    'الحزب $opt';
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
                                        vertical: 6,
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
                                            .bodyMedium!
                                            .copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  ResponsiveUtils.sp(
                                                    context,
                                                    16,
                                                  ) *
                                                  settings.fontScale,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 12),
                            ],
                            if (_mode != QuizMode.orderHizb) ...[
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
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
