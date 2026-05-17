/// Workout Repository — wrap WorkoutService dengan parsing model.
import 'package:heltigo/data/services/workout_service.dart';
import 'package:heltigo/data/models/workout_model.dart';

abstract class WorkoutRepository {
  Future<WorkoutDayModel?> getTodayWorkout();
  Future<WorkoutDayModel?> getWorkoutDayDetail(String dayId);
  Future<Map<String, dynamic>> getExerciseDetail(String exerciseId);
  Future<Map<String, dynamic>> checkIn(String dayId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getSessionDetail(String sessionId);
  Future<Map<String, dynamic>> completeSession(
      String sessionId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> pauseSession(String sessionId);
  Future<Map<String, dynamic>> updateExercise(
      String sessionId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> swapExercise(
      String exerciseId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getSessionsHistory({int limit = 20});
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutService _service;

  WorkoutRepositoryImpl(this._service);

  @override
  Future<WorkoutDayModel?> getTodayWorkout() async {
    final json = await _service.getTodayWorkout();
    final day = json['day'];
    if (day is Map<String, dynamic>) {
      return WorkoutDayModel.fromJson(day);
    }
    return null;
  }

  @override
  Future<WorkoutDayModel?> getWorkoutDayDetail(String dayId) async {
    final json = await _service.getWorkoutDayDetail(dayId);
    final day = json['day'];
    if (day is Map<String, dynamic>) {
      return WorkoutDayModel.fromJson(day);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> getExerciseDetail(String exerciseId) =>
      _service.getExerciseDetail(exerciseId);

  @override
  Future<Map<String, dynamic>> checkIn(
          String dayId, Map<String, dynamic> data) =>
      _service.checkIn(dayId, data);

  @override
  Future<Map<String, dynamic>> getSessionDetail(String sessionId) =>
      _service.getSessionDetail(sessionId);

  @override
  Future<Map<String, dynamic>> completeSession(
          String sessionId, Map<String, dynamic> data) =>
      _service.completeSession(sessionId, data);

  @override
  Future<Map<String, dynamic>> pauseSession(String sessionId) =>
      _service.pauseSession(sessionId);

  @override
  Future<Map<String, dynamic>> updateExercise(
          String sessionId, Map<String, dynamic> data) =>
      _service.updateExercise(sessionId, data);

  @override
  Future<Map<String, dynamic>> swapExercise(
          String exerciseId, Map<String, dynamic> data) =>
      _service.swapExercise(exerciseId, data);

  @override
  Future<List<Map<String, dynamic>>> getSessionsHistory(
      {int limit = 20}) async {
    final json = await _service.getSessionsHistory(limit: limit);
    final sessions = json['sessions'];
    if (sessions is List) {
      return sessions.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return [];
  }
}
