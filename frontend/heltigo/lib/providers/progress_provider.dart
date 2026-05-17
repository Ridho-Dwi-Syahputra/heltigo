/// Progress Provider — state management untuk progress harian, mingguan,
/// streak, dan badges.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/progress_repository.dart';
import 'package:heltigo/data/models/progress_model.dart';
import 'package:heltigo/data/models/badge_model.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repo;

  bool _isLoading = false;
  DailyProgressModel? _daily;
  WeeklyProgressModel? _weekly;
  Map<String, dynamic>? _weeklyReview;
  StreakModel? _streak;
  List<BadgeModel> _badges = [];
  String? _errorMessage;

  ProgressProvider(this._repo);

  bool get isLoading => _isLoading;
  DailyProgressModel? get daily => _daily;
  WeeklyProgressModel? get weekly => _weekly;
  Map<String, dynamic>? get weeklyReview => _weeklyReview;
  StreakModel? get streak => _streak;
  List<BadgeModel> get badges => _badges;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDaily({String? date}) async {
    try {
      _daily = await _repo.getDailyProgress(date: date);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<void> fetchWeekly() async {
    _isLoading = true;
    notifyListeners();
    try {
      _weekly = await _repo.getWeeklyProgress();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeeklyReview() async {
    try {
      _weeklyReview = await _repo.getWeeklyReview();
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<void> fetchStreak() async {
    try {
      _streak = await _repo.getStreak();
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<void> fetchBadges() async {
    try {
      _badges = await _repo.getBadges();
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<bool> updateWater({int? glasses, int? delta}) async {
    try {
      final result = await _repo.updateWater(glasses: glasses, delta: delta);
      final newGlasses = (result['waterGlasses'] as num?)?.toInt();
      if (newGlasses != null && _daily != null) {
        _daily = DailyProgressModel(
          date: _daily!.date,
          workoutCompleted: _daily!.workoutCompleted,
          workoutSessionId: _daily!.workoutSessionId,
          mealsLoggedCount: _daily!.mealsLoggedCount,
          mealsTotal: _daily!.mealsTotal,
          waterGlasses: newGlasses,
          waterTarget: _daily!.waterTarget,
          mood: _daily!.mood,
          dailyScore: _daily!.dailyScore,
          caloriesConsumed: _daily!.caloriesConsumed,
          caloriesBurned: _daily!.caloriesBurned,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> logMood(String mood) async {
    try {
      await _repo.logMood(mood);
      await fetchDaily();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}
