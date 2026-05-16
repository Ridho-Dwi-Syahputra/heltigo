/// Meal Service — komunikasi API untuk meal endpoints
/// Sumber: docs/frontend/08_API_INTEGRATION.md
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class MealService {
  final ApiService _apiService;

  MealService(this._apiService);

  /// GET /meal/today — ambil rencana makan hari ini
  Future<Map<String, dynamic>> getTodayMeal() async {
    final response = await _apiService.get(ApiEndpoints.todayMeal);
    return response.data as Map<String, dynamic>;
  }

  /// GET /meal/:id — detail rencana makan
  Future<Map<String, dynamic>> getMealDetail(String id) async {
    final response = await _apiService.get(ApiEndpoints.mealDetail(id));
    return response.data as Map<String, dynamic>;
  }

  /// POST /meal/:id/log — log makanan dimakan
  Future<Map<String, dynamic>> logMeal(
      String id, Map<String, dynamic> data) async {
    final response =
        await _apiService.post(ApiEndpoints.mealLog(id), data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST /meal/:id/swap — swap makanan dengan alternatif
  Future<Map<String, dynamic>> swapMeal(
      String id, Map<String, dynamic> data) async {
    final response =
        await _apiService.post(ApiEndpoints.mealSwap(id), data: data);
    return response.data as Map<String, dynamic>;
  }
}
