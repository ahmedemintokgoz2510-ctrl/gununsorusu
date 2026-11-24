import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/builtin_questions.dart';
import '../models/question.dart';
import '../utils/date_utils.dart';

class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  final List<Question> _custom = [];

  ThemeMode themeMode = ThemeMode.system;
  int totalAnswered = 0;
  int totalCorrect = 0;
  int streak = 0;
  int bestStreak = 0;
  String lastAnsweredDate = '';

  Question? _today;
  String _todayKey = '';

  List<Question> get allQuestions => [...builtInQuestions, ..._custom];

  List<String> get categories {
    final set = <String>{};
    for (final q in allQuestions) {
      set.add(q.category);
    }
    final list = set.toList()..sort();
    return ['Tümü', ...list];
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    final raw = _prefs.getString('custom_questions');
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          _custom.add(Question.fromJson(Map<String, dynamic>.from(item as Map)));
        }
      } catch (_) {
        // Bozuk veri varsa yok say.
      }
    }

    final t = _prefs.getInt('theme') ?? 0;
    themeMode = (t >= 0 && t < ThemeMode.values.length)
        ? ThemeMode.values[t]
        : ThemeMode.system;

    totalAnswered = _prefs.getInt('total_answered') ?? 0;
    totalCorrect = _prefs.getInt('total_correct') ?? 0;
    streak = _prefs.getInt('streak') ?? 0;
    bestStreak = _prefs.getInt('best_streak') ?? 0;
    lastAnsweredDate = _prefs.getString('last_answered') ?? '';
  }

  /// Bugünün sorusu: gün içinde sabit kalır.
  Question get todayQuestion {
    final now = DateTime.now();
    final key = dateKey(now);
    if (_todayKey == key && _today != null) return _today!;

    final all = allQuestions;
    final savedId = _prefs.getString('daily_id_$key');
    Question? found;
    if (savedId != null) {
      for (final q in all) {
        if (q.id == savedId) {
          found = q;
          break;
        }
      }
    }
    if (found == null) {
      final days = DateTime(now.year, now.month, now.day)
          .difference(DateTime(2024, 1, 1))
          .inDays;
      found = all[days.abs() % all.length];
      _prefs.setString('daily_id_$key', found.id);
    }
    _todayKey = key;
    _today = found;
    return found;
  }

  int? get todayAnswer => _prefs.getInt('answer_${dateKey(DateTime.now())}');

  /// Ekranda gösterilen güncel seri (dün veya bugün cevaplanmadıysa 0).
  int get currentStreak {
    final now = DateTime.now();
    final today = dateKey(now);
    final yesterday = dateKey(DateTime(now.year, now.month, now.day - 1));
    if (lastAnsweredDate == today || lastAnsweredDate == yesterday) {
      return streak;
    }
    return 0;
  }

  Future<void> answerToday(int index) async {
    if (todayAnswer != null) return;
    final q = todayQuestion;
    final now = DateTime.now();
    final today = dateKey(now);
    final yesterday = dateKey(DateTime(now.year, now.month, now.day - 1));

    await _prefs.setInt('answer_$today', index);

    totalAnswered++;
    if (index == q.correctIndex) totalCorrect++;
    streak = (lastAnsweredDate == yesterday) ? streak + 1 : 1;
    if (streak > bestStreak) bestStreak = streak;
    lastAnsweredDate = today;

    await _saveStats();
    notifyListeners();
  }

  Future<void> addQuestion({
    required String text,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    required String category,
  }) async {
    _custom.add(Question(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      category: category,
      isCustom: true,
    ));
    await _saveCustom();
    notifyListeners();
  }

  Future<void> deleteQuestion(String id) async {
    _custom.removeWhere((q) => q.id == id);
    if (_today?.id == id) {
      _today = null;
      _todayKey = '';
      await _prefs.remove('daily_id_${dateKey(DateTime.now())}');
    }
    await _saveCustom();
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode = mode;
    await _prefs.setInt('theme', mode.index);
    notifyListeners();
  }

  /// İstatistikleri sıfırlar ve bugünün cevabını siler (tekrar denenebilir).
  Future<void> resetStats() async {
    totalAnswered = 0;
    totalCorrect = 0;
    streak = 0;
    bestStreak = 0;
    lastAnsweredDate = '';
    await _prefs.remove('answer_${dateKey(DateTime.now())}');
    await _saveStats();
    notifyListeners();
  }

  Future<void> _saveStats() async {
    await _prefs.setInt('total_answered', totalAnswered);
    await _prefs.setInt('total_correct', totalCorrect);
    await _prefs.setInt('streak', streak);
    await _prefs.setInt('best_streak', bestStreak);
    await _prefs.setString('last_answered', lastAnsweredDate);
  }

  Future<void> _saveCustom() async {
    await _prefs.setString(
      'custom_questions',
      jsonEncode(_custom.map((q) => q.toJson()).toList()),
    );
  }
}
