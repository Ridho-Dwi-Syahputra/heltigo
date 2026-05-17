/// Meal Service — komunikasi API untuk meal endpoints
/// Disesuaikan dengan backend routes: /meal/*
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

  /// GET /meal/day/:dayId — detail hari makan tertentu
  Future<Map<String, dynamic>> getMealDayDetail(String dayId) async {
    final response =
        await _apiService.get(ApiEndpoints.mealDayDetail(dayId));
    return response.data as Map<String, dynamic>;
  }

  /// GET /meal/:mealId — detail meal time (sarapan/makan siang/dll)
  Future<Map<String, dynamic>> getMealDetail(String mealId) async {
    final response = await _apiService.get(ApiEndpoints.mealDetail(mealId));
    return response.data as Map<String, dynamic>;
  }

  /// GET /meal/food/:foodId — detail food item
  Future<Map<String, dynamic>> getFoodDetail(String foodId) async {
    final response = await _apiService.get(ApiEndpoints.foodDetail(foodId));
    return response.data as Map<String, dynamic>;
  }

  /// GET /meal/log — riwayat log makanan (default 7 hari)
  Future<Map<String, dynamic>> getMealLog({int days = 7}) async {
    final response = await _apiService.get(
      ApiEndpoints.mealLog,
      queryParameters: {'days': days},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /meal/:mealId/log — log makanan dimakan
  Future<Map<String, dynamic>> logMeal(
      String mealId, Map<String, dynamic> data) async {
    final response =
        await _apiService.post(ApiEndpoints.logMeal(mealId), data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST /meal/:mealId/swap — swap makanan dengan alternatif dari ML + Gemini
  Future<Map<String, dynamic>> swapMeal(
      String mealId, Map<String, dynamic> data) async {
    final response =
        await _apiService.post(ApiEndpoints.mealSwap(mealId), data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST /meal/:mealId/replace — konfirmasi replace setelah memilih alternatif
  Future<Map<String, dynamic>> replaceMeal(
      String mealId, Map<String, dynamic> data) async {
    final response =
        await _apiService.post(ApiEndpoints.mealReplace(mealId), data: data);
    return response.data as Map<String, dynamic>;
  }

  /// PUT /meal/budget — update budget harian
  Future<Map<String, dynamic>> updateBudget(int budgetPerDayIdr) async {
    final response = await _apiService.put(
      ApiEndpoints.updateBudget,
      data: {'budgetPerDayIdr': budgetPerDayIdr},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /meal/food-scan — scan foto makanan via Gemini Vision + ML
  /// [imageBase64] — base64 gambar (tanpa prefix data:image/...)
  /// [identifiedFoods] — atau kirim list nama makanan langsung
  /// [persist] — jika true, kalori tercatat ke daily_logs
  Future<Map<String, dynamic>> foodScan({
    String? imageBase64,
    List<String>? identifiedFoods,
    List<double>? portions,
    bool persist = false,
  }) async {
    final body = <String, dynamic>{'persist': persist};
    if (imageBase64 != null) body['imageBase64'] = imageBase64;
    if (identifiedFoods != null) body['identifiedFoods'] = identifiedFoods;
    if (portions != null) body['portions'] = portions;

    final response = await _apiService.post(
      ApiEndpoints.foodScan,
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }
}
