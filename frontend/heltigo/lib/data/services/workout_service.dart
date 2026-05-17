/// Workout Service — komunikasi API untuk workout endpoints.
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class WorkoutService {
  final ApiService _apiService;

  WorkoutService(this._apiService);

  Future<Map<String, dynamic>> getTodayWorkout() async {
    final res = await _apiService.get(ApiEndpoints.todayWorkout);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWorkoutDayDetail(String dayId) async {
    final res = await _apiService.get(ApiEndpoints.workoutDayDetail(dayId));
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExerciseDetail(String exerciseId) async {
    final res =
        await _apiService.get(ApiEndpoints.workoutExerciseDetail(exerciseId));
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkIn(
      String dayId, Map<String, dynamic> data) async {
    final res = await _apiService.post(
      ApiEndpoints.workoutCheckIn(dayId),
      data: data,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionDetail(String sessionId) async {
    final res =
        await _apiService.get(ApiEndpoints.workoutSessionDetail(sessionId));
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completeSession(
      String sessionId, Map<String, dynamic> data) async {
    final res = await _apiService.post(
      ApiEndpoints.workoutSessionComplete(sessionId),
      data: data,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pauseSession(String sessionId) async {
    final res = await _apiService.post(
      ApiEndpoints.workoutSessionPause(sessionId),
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateExercise(
      String sessionId, Map<String, dynamic> data) async {
    final res = await _apiService.patch(
      ApiEndpoints.workoutSessionUpdateExercise(sessionId),
      data: data,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> swapExercise(
      String exerciseId, Map<String, dynamic> data) async {
    final res = await _apiService.post(
      ApiEndpoints.workoutExerciseSwap(exerciseId),
      data: data,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionsHistory({int limit = 20}) async {
    final res = await _apiService.get(
      ApiEndpoints.workoutSessions,
      queryParameters: {'limit': limit},
    );
    return res.data as Map<String, dynamic>;
  }
}
