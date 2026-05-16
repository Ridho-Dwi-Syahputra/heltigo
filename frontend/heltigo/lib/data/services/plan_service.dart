/// Plan Service — komunikasi API untuk plan generation & management
/// Sumber: docs/frontend/08_API_INTEGRATION.md
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class PlanService {
  final ApiService _apiService;

  PlanService(this._apiService);

  /// POST /plan/generate — generate rencana baru dari ML
  Future<Map<String, dynamic>> generatePlan() async {
    final response = await _apiService.post(ApiEndpoints.generatePlan);
    return response.data as Map<String, dynamic>;
  }

  /// GET /plan/active — ambil rencana aktif saat ini
  Future<Map<String, dynamic>> getActivePlan() async {
    final response = await _apiService.get(ApiEndpoints.activePlan);
    return response.data as Map<String, dynamic>;
  }

  /// GET /plan/history — riwayat rencana sebelumnya
  Future<Map<String, dynamic>> getPlanHistory() async {
    final response = await _apiService.get(ApiEndpoints.planHistory);
    return response.data as Map<String, dynamic>;
  }

  /// POST /plan/replan — trigger replanning
  Future<Map<String, dynamic>> requestReplan() async {
    final response = await _apiService.post(ApiEndpoints.replan);
    return response.data as Map<String, dynamic>;
  }
}
