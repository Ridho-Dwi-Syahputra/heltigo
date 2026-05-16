/// Meal Repository — abstraksi akses data meal
/// Sumber: docs/frontend/02_PROJECT_STRUCTURE.md
import 'package:heltigo/data/services/meal_service.dart';

abstract class MealRepository {
  Future<Map<String, dynamic>> getTodayMeal();
  Future<Map<String, dynamic>> getMealDetail(String id);
  Future<Map<String, dynamic>> logMeal(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> swapMeal(String id, Map<String, dynamic> data);
}

class MealRepositoryImpl implements MealRepository {
  final MealService _mealService;

  MealRepositoryImpl(this._mealService);

  @override
  Future<Map<String, dynamic>> getTodayMeal() => _mealService.getTodayMeal();

  @override
  Future<Map<String, dynamic>> getMealDetail(String id) =>
      _mealService.getMealDetail(id);

  @override
  Future<Map<String, dynamic>> logMeal(
          String id, Map<String, dynamic> data) =>
      _mealService.logMeal(id, data);

  @override
  Future<Map<String, dynamic>> swapMeal(
          String id, Map<String, dynamic> data) =>
      _mealService.swapMeal(id, data);
}
