import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:google_fonts/google_fonts.dart';

class ThumonSearchDelegate extends SearchDelegate<int?> {
  final ThemeSettings settings;
  final List<ThumonEntry> filenames;
  Map<int, String>? _textCache;
  List<_ThumonSearchResult>? _allData;

  ThumonSearchDelegate({required this.settings, required this.filenames});

  @override
  String get searchFieldLabel => 'بحث في الأثمان...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: settings.backgroundGradient[0],
        iconTheme: IconThemeData(color: settings.primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: settings.textColor.withAlpha(150)),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(color: settings.textColor),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  Future<void> _ensureDataLoaded() async {
    if (_allData != null) return;

    final data = <_ThumonSearchResult>[];
    for (int i = 0; i < filenames.length; i++) {
      final text = await rootBundle.loadString(
        'lib/thomuns_txt/${filenames[i].file}',
      );
      data.add(
        _ThumonSearchResult(
          index: i,
          filename: filenames[i].file,
          originalText: text,
        ),
      );
    }

    _allData = data;
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) {
      return Center(
        child: Text(
          'أدخل حرفين على الأقل للبحث',
          style: TextStyle(color: settings.textColor.withAlpha(150)),
        ),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder(
      future: _ensureDataLoaded(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final normalizedQuery = _normalizeArabic(query);
        final results = _allData!.where((item) {
          return item.normalizedText.contains(normalizedQuery);
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              'لا توجد نتائج',
              style: TextStyle(color: settings.textColor),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: settings.backgroundGradient,
            ),
          ),
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultTile(context, result, normalizedQuery);
            },
          ),
        );
      },
    );
  }

  Widget _buildResultTile(
    BuildContext context,
    _ThumonSearchResult result,
    String normalizedQuery,
  ) {
    final filename = result.filename.replaceAll('.txt', '');
    final parts = filename.split('-');

    // Find snippet
    final matchIndex = result.normalizedText.indexOf(normalizedQuery);
    String snippet = '';
    if (matchIndex != -1) {
      // We want to show original text snippet
      // Mapping normalized index to original is hard, so we'll just show a part of original
      // and highlight the match.
      // For simplicity, we'll find the match in original by stripping diacritics in a window.
      snippet = _getSnippet(result.originalText, query);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: settings.isDarkMode
          ? Colors.white.withAlpha(10)
          : Colors.black.withAlpha(5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الحزب ${parts[0]} - الثمن ${parts[1]}',
                style: TextStyle(
                  color: settings.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        subtitle: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              snippet,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: settings.textColor.withAlpha(200),
                fontFamily: settings.fontFamily,
                fontSize: ResponsiveUtils.sp(context, 14) * settings.fontScale,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        onTap: () {
          close(context, result.index);
        },
      ),
    );
  }

  String _getSnippet(String originalText, String query) {
    final normalizedOriginal = _normalizeArabic(originalText);
    final normalizedQuery = _normalizeArabic(query);
    final matchIndex = normalizedOriginal.indexOf(normalizedQuery);

    if (matchIndex == -1)
      return originalText.length > 120
          ? originalText.substring(0, 120) + '...'
          : originalText;

    // We try to find a window in original that corresponds to the match
    // This is an approximation
    int start = (matchIndex - 40).clamp(0, normalizedOriginal.length);
    int end = (matchIndex + normalizedQuery.length + 40).clamp(
      0,
      normalizedOriginal.length,
    );

    // Since original has more chars (diacritics), we need to expand the window
    // A safe factor is 2x
    int origStart = (matchIndex * 1.5).toInt() - 60;
    int origEnd = ((matchIndex + normalizedQuery.length) * 2.5).toInt() + 60;

    // Better way: iterate through original and count non-diacritic chars
    int currentNormCount = 0;
    int finalStart = 0;
    int finalEnd = originalText.length;
    bool startFound = false;

    final diacritics = RegExp(r'[\u064B-\u0652\u0671\u0670]');

    for (int i = 0; i < originalText.length; i++) {
      if (!originalText[i].contains(diacritics)) {
        if (!startFound &&
            currentNormCount >= (matchIndex - 20).clamp(0, matchIndex)) {
          finalStart = i;
          startFound = true;
        }
        if (currentNormCount >= matchIndex + normalizedQuery.length + 20) {
          finalEnd = i;
          break;
        }
        currentNormCount++;
      }
    }

    String result = originalText.substring(finalStart, finalEnd).trim();
    if (finalStart > 0) result = '...' + result;
    if (finalEnd < originalText.length) result = result + '...';
    return result;
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ـ', '');
  }
}

class _ThumonSearchResult {
  final int index;
  final String filename;
  final String originalText;
  final String normalizedText;

  _ThumonSearchResult({
    required this.index,
    required this.filename,
    required this.originalText,
  }) : normalizedText = _normalize(originalText);

  static String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ـ', '');
  }
}
