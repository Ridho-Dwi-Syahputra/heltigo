/// Workout Service — komunikasi API untuk workout endpoints
/// Sumber: docs/frontend/08_API_INTEGRATION.md
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class WorkoutService {
  final ApiService _apiService;

  WorkoutService(this._apiService);

  /// GET /workout/today — ambil workout hari ini
  Future<Map<String, dynamic>> getTodayWorkout() async {
    final response = await _apiService.get(ApiEndpoints.todayWorkout);
    return response.data as Map<String, dynamic>;
  }

  /// GET /workout/:id — detail workout
  Future<Map<String, dynamic>> getWorkoutDetail(String id) async {
    final response =
        await _apiService.get(ApiEndpoints.workoutDetail(id));
    return response.data as Map<String, dynamic>;
  }

  /// POST /workout/:id/check-in — pre-workout check-in
  Future<Map<String, dynamic>> checkIn(
      String id, Map<String, dynamic> data) async {
    final response = await _apiService.post(
      ApiEndpoints.workoutCheckIn(id),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /workout/:id/complete — selesaikan workout
  Future<Map<String, dynamic>> completeWorkout(String id) async {
    final response =
        await _apiService.post(ApiEndpoints.workoutComplete(id));
    return response.data as Map<String, dynamic>;
  }

  /// PATCH /workout/:id/exercise/complete — tandai exercise selesai
  Future<Map<String, dynamic>> completeExercise(
      String workoutId, Map<String, dynamic> data) async {
    final response = await _apiService.patch(
      ApiEndpoints.exerciseComplete(workoutId),
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }
}
