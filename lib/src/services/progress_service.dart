import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  static final ProgressService instance = ProgressService._();
  ProgressService._();

  Set<int> _learnedThomuns = {};
  Set<int> _revisedThomuns = {};

  Set<int> get learnedThomuns => _learnedThomuns;
  Set<int> get revisedThomuns => _revisedThomuns;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedList = prefs.getStringList('learned_thomuns_txt') ?? [];
    final revisedList = prefs.getStringList('revised_thomuns_txt') ?? [];
    
    _learnedThomuns = learnedList.map((e) => int.tryParse(e) ?? 0).toSet();
    _revisedThomuns = revisedList.map((e) => int.tryParse(e) ?? 0).toSet();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleLearned(int index) async {
    if (_learnedThomuns.contains(index)) {
      _learnedThomuns.remove(index);
    } else {
      _learnedThomuns.add(index);
    }
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'learned_thomuns_txt',
      _learnedThomuns.map((e) => e.toString()).toList(),
    );
  }

  Future<void> toggleRevised(int index) async {
    if (_revisedThomuns.contains(index)) {
      _revisedThomuns.remove(index);
    } else {
      _revisedThomuns.add(index);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'revised_thomuns_txt',
      _revisedThomuns.map((e) => e.toString()).toList(),
    );
  }
}

final progressService = ProgressService.instance;
