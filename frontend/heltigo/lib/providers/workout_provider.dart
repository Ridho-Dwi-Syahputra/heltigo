/// Workout Provider — state management untuk workout tracking
/// Sumber: docs/frontend/06_STATE_MANAGEMENT.md
import 'package:flutter/material.dart';
import 'package:heltigo/data/repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  bool _isLoading = false;
  Map<String, dynamic>? _todayWorkout;
  String? _errorMessage;

  WorkoutProvider(this._workoutRepository);

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get todayWorkout => _todayWorkout;
  String? get errorMessage => _errorMessage;

  /// Fetch workout hari ini
  Future<void> fetchTodayWorkout() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todayWorkout = await _workoutRepository.getTodayWorkout();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Pre-workout check-in (mood, energi, cedera)
  Future<bool> checkIn(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _workoutRepository.checkIn(id, data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Complete workout
  Future<bool> completeWorkout(String id) async {
    try {
      await _workoutRepository.completeWorkout(id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
