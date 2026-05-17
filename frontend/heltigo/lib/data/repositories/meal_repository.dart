/// Meal Repository — wrap MealService dengan parsing model.
import 'package:heltigo/data/services/meal_service.dart';
import 'package:heltigo/data/models/meal_model.dart';

abstract class MealRepository {
  Future<MealDayModel?> getTodayMeal();
  Future<MealDayModel?> getMealDayDetail(String dayId);
  Future<MealTimeModel?> getMealDetail(String mealId);
  Future<Map<String, dynamic>> getFoodDetail(String foodId);
  Future<Map<String, dynamic>> getMealLog({int days = 7});
  Future<Map<String, dynamic>> logMeal(String mealId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> swapMeal(
      String mealId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> replaceMeal(
      String mealId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateBudget(int budgetPerDayIdr);
  Future<Map<String, dynamic>> foodScan({
    String? imageBase64,
    List<String>? identifiedFoods,
    List<double>? portions,
    bool persist = false,
  });
}

class MealRepositoryImpl implements MealRepository {
  final MealService _service;

  MealRepositoryImpl(this._service);

  @override
  Future<MealDayModel?> getTodayMeal() async {
    final json = await _service.getTodayMeal();
    final day = json['day'];
    if (day is Map<String, dynamic>) return MealDayModel.fromJson(day);
    return null;
  }

  @override
  Future<MealDayModel?> getMealDayDetail(String dayId) async {
    final json = await _service.getMealDayDetail(dayId);
    final day = json['day'];
    if (day is Map<String, dynamic>) return MealDayModel.fromJson(day);
    return null;
  }

  @override
  Future<MealTimeModel?> getMealDetail(String mealId) async {
    final json = await _service.getMealDetail(mealId);
    final meal = json['meal'];
    if (meal is Map<String, dynamic>) return MealTimeModel.fromJson(meal);
    return null;
  }

  @override
  Future<Map<String, dynamic>> getFoodDetail(String foodId) =>
      _service.getFoodDetail(foodId);

  @override
  Future<Map<String, dynamic>> getMealLog({int days = 7}) =>
      _service.getMealLog(days: days);

  @override
  Future<Map<String, dynamic>> logMeal(
          String mealId, Map<String, dynamic> data) =>
      _service.logMeal(mealId, data);

  @override
  Future<Map<String, dynamic>> swapMeal(
          String mealId, Map<String, dynamic> data) =>
      _service.swapMeal(mealId, data);

  @override
  Future<Map<String, dynamic>> replaceMeal(
          String mealId, Map<String, dynamic> data) =>
      _service.replaceMeal(mealId, data);

  @override
  Future<Map<String, dynamic>> updateBudget(int budgetPerDayIdr) =>
      _service.updateBudget(budgetPerDayIdr);

  @override
  Future<Map<String, dynamic>> foodScan({
    String? imageBase64,
    List<String>? identifiedFoods,
    List<double>? portions,
    bool persist = false,
  }) =>
      _service.foodScan(
        imageBase64: imageBase64,
        identifiedFoods: identifiedFoods,
        portions: portions,
        persist: persist,
      );
}
