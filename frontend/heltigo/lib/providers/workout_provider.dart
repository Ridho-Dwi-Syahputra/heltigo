/// Workout Provider — state management untuk workout tracking lifecycle.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/workout_repository.dart';
import 'package:heltigo/data/models/workout_model.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repo;

  bool _isLoading = false;
  WorkoutDayModel? _todayWorkout;
  Map<String, dynamic>? _activeSession;
  Map<String, dynamic>? _lastCompleteResult; // dari /complete (stats + gemini)
  List<Map<String, dynamic>> _sessionsHistory = [];
  String? _errorMessage;

  WorkoutProvider(this._repo);

  bool get isLoading => _isLoading;
  WorkoutDayModel? get todayWorkout => _todayWorkout;
  Map<String, dynamic>? get activeSession => _activeSession;
  Map<String, dynamic>? get lastCompleteResult => _lastCompleteResult;
  List<Map<String, dynamic>> get sessionsHistory => _sessionsHistory;
  String? get errorMessage => _errorMessage;
  String? get geminiCongrats =>
      _lastCompleteResult?['message']?.toString();

  Future<void> fetchTodayWorkout() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todayWorkout = await _repo.getTodayWorkout();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<WorkoutDayModel?> getDayDetail(String dayId) async {
    try {
      return await _repo.getWorkoutDayDetail(dayId);
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return null;
    }
  }

  /// Pre-workout check-in → returns sessionId.
  Future<String?> checkIn(
    String dayId, {
    required String mood,
    required int energy,
    required String sleepBand,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _repo.checkIn(dayId, {
        'mood': mood,
        'energy': energy,
        'sleepBand': sleepBand,
      });
      _activeSession = result;
      _isLoading = false;
      notifyListeners();
      final session = result['session'] as Map<String, dynamic>?;
      return session?['id']?.toString();
    } catch (e) {
      _errorMessage = _msg(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateExerciseLog(
    String sessionId, {
    required String exerciseId,
    required int setNumber,
    int? repsActual,
    int? durationActualSec,
    double? weightKg,
    int? restActualSec,
    bool isCompleted = true,
  }) async {
    try {
      await _repo.updateExercise(sessionId, {
        'exerciseId': exerciseId,
        'setNumber': setNumber,
        if (repsActual != null) 'repsActual': repsActual,
        if (durationActualSec != null) 'durationActualSec': durationActualSec,
        if (weightKg != null) 'weightKg': weightKg,
        if (restActualSec != null) 'restActualSec': restActualSec,
        'isCompleted': isCompleted,
      });
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeSession(
    String sessionId, {
    int? effortScore,
    String? moodAfter,
    String? notes,
  }) async {
    try {
      _lastCompleteResult = await _repo.completeSession(sessionId, {
        if (effortScore != null) 'effortScore': effortScore,
        if (moodAfter != null) 'moodAfter': moodAfter,
        if (notes != null) 'notes': notes,
      });
      _activeSession = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> pauseSession(String sessionId) async {
    try {
      await _repo.pauseSession(sessionId);
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<void> fetchSessionsHistory({int limit = 20}) async {
    try {
      _sessionsHistory = await _repo.getSessionsHistory(limit: limit);
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getSessionDetail(String sessionId) async {
    try {
      return await _repo.getSessionDetail(sessionId);
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearLastResult() {
    _lastCompleteResult = null;
    notifyListeners();
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}
