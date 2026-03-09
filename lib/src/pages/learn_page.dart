import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/constants.dart';

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
    await prefs.setStringList('learned_thomuns', _learnedThomuns.map((e) => e.toString()).toList());
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
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232537), Color(0xFF12121D)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('إحفظ : ${kThomuns[_currentIndex].replaceAll('.png', '')}', style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2)),
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
                        child: Image.asset('lib/thomuns/${kThomuns[index]}', fit: BoxFit.contain, width: double.infinity, height: double.infinity),
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
                          style: TextStyle(color: _learnedThomuns.contains(_currentIndex) ? const Color(0xFF64FFDA) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentIndex + 1} / ${kThomuns.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64FFDA), fontSize: 12),
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
