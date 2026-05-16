/// Workout Repository — abstraksi akses data workout
/// Sumber: docs/frontend/02_PROJECT_STRUCTURE.md
import 'package:heltigo/data/services/workout_service.dart';

abstract class WorkoutRepository {
  Future<Map<String, dynamic>> getTodayWorkout();
  Future<Map<String, dynamic>> getWorkoutDetail(String id);
  Future<Map<String, dynamic>> checkIn(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> completeWorkout(String id);
  Future<Map<String, dynamic>> completeExercise(
      String workoutId, Map<String, dynamic> data);
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutService _workoutService;

  WorkoutRepositoryImpl(this._workoutService);

  @override
  Future<Map<String, dynamic>> getTodayWorkout() =>
      _workoutService.getTodayWorkout();

  @override
  Future<Map<String, dynamic>> getWorkoutDetail(String id) =>
      _workoutService.getWorkoutDetail(id);

  @override
  Future<Map<String, dynamic>> checkIn(
          String id, Map<String, dynamic> data) =>
      _workoutService.checkIn(id, data);

  @override
  Future<Map<String, dynamic>> completeWorkout(String id) =>
      _workoutService.completeWorkout(id);

  @override
  Future<Map<String, dynamic>> completeExercise(
          String workoutId, Map<String, dynamic> data) =>
      _workoutService.completeExercise(workoutId, data);
}
