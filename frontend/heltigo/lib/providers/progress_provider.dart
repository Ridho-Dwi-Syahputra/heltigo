/// Progress Provider — state management untuk progress, streak, badges
/// Sumber: docs/frontend/06_STATE_MANAGEMENT.md
import 'package:flutter/material.dart';
import 'package:heltigo/data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepository;

  bool _isLoading = false;
  Map<String, dynamic>? _weeklyProgress;
  Map<String, dynamic>? _streak;
  Map<String, dynamic>? _badges;
  String? _errorMessage;

  ProgressProvider(this._progressRepository);

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get weeklyProgress => _weeklyProgress;
  Map<String, dynamic>? get streak => _streak;
  Map<String, dynamic>? get badges => _badges;
  String? get errorMessage => _errorMessage;

  /// Fetch weekly progress summary
  Future<void> fetchWeeklyProgress() async {
    _isLoading = true;
    notifyListeners();
    try {
      _weeklyProgress = await _progressRepository.getWeeklyProgress();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch streak data
  Future<void> fetchStreak() async {
    try {
      _streak = await _progressRepository.getStreak();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Fetch badges
  Future<void> fetchBadges() async {
    try {
      _badges = await _progressRepository.getBadges();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
