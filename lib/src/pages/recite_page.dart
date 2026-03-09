import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/constants.dart';

class RecitePage extends StatefulWidget {
  const RecitePage({super.key});

  @override
  State<RecitePage> createState() => _RecitePageState();
}

class _RecitePageState extends State<RecitePage> {
  String? _currentThomun;
  final Random _random = Random();

  /// when true we limit picks to the thomuns the user has marked as
  /// learned.  The toggle is exposed in the app bar.
  bool _onlyLearned = false;

  Future<void> _generateRandomThomun() async {
    List<String> pool = kThomuns;

    if (_onlyLearned) {
      final prefs = await SharedPreferences.getInstance();
      final learnedList = prefs.getStringList('learned_thomuns') ?? [];
      if (learnedList.isNotEmpty) {
        // map saved indices back to filenames, ignoring any invalid values
        final filtered = learnedList
            .map(int.tryParse)
            .whereType<int>()
            .where((i) => i >= 0 && i < kThomuns.length)
            .map((i) => kThomuns[i])
            .toList();
        if (filtered.isNotEmpty) pool = filtered;
      }
    }

    setState(() {
      int randomIndex = _random.nextInt(pool.length);
      _currentThomun = pool[randomIndex];
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
                : 'إمتحن حفظك',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _onlyLearned ? Icons.check_box : Icons.check_box_outline_blank,
                color: _onlyLearned ? const Color(0xFF64FFDA) : Colors.white,
              ),
              tooltip: 'اختر من الحفظ فقط',
              onPressed: () {
                setState(() {
                  _onlyLearned = !_onlyLearned;
                });
              },
            ),
          ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shuffle,
                          size: 28,
                          color: Color(0xFF12121D),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _onlyLearned ? 'من المحفوظات' : 'اختيار ثمن عشوائي',
                          style: const TextStyle(
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
