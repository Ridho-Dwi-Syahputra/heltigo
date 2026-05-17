/// Plan Service — komunikasi API untuk plan generation & management.
/// Backend response shape:
///   POST /plan/generate  →  { status, data: { workoutPlan, mealPlan } }
///   GET  /plan/active    →  { workoutPlan, mealPlan }
///   GET  /plan/history   →  { plans: [...] }
///   POST /plan/replan    →  { status, data: { summary, ml, narrative, regeneratedPlan } }
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class PlanService {
  final ApiService _apiService;

  PlanService(this._apiService);

  Future<Map<String, dynamic>> generatePlan({
    bool workoutOnly = false,
    bool mealOnly = false,
  }) async {
    final res = await _apiService.post(
      ApiEndpoints.generatePlan,
      data: {
        if (workoutOnly) 'workoutOnly': true,
        if (mealOnly) 'mealOnly': true,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getActivePlan() async {
    final res = await _apiService.get(ApiEndpoints.activePlan);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPlanHistory() async {
    final res = await _apiService.get(ApiEndpoints.planHistory);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPlanById(String id) async {
    final res = await _apiService.get(ApiEndpoints.planById(id));
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> requestReplan({
    bool applyImmediately = false,
  }) async {
    final res = await _apiService.post(
      ApiEndpoints.replan,
      data: {'applyImmediately': applyImmediately},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<void> replanSkip() async {
    await _apiService.post(ApiEndpoints.replanSkip);
  }
}
