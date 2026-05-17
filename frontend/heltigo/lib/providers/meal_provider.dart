/// Meal Provider — state management untuk meal plan, logging, food scan.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/meal_repository.dart';
import 'package:heltigo/data/models/meal_model.dart';

class MealProvider extends ChangeNotifier {
  final MealRepository _repo;

  bool _isLoading = false;
  MealDayModel? _todayMeal;
  Map<String, dynamic>? _lastScanResult;
  Map<String, dynamic>? _lastSwapResult;
  String? _errorMessage;

  MealProvider(this._repo);

  bool get isLoading => _isLoading;
  MealDayModel? get todayMeal => _todayMeal;
  Map<String, dynamic>? get lastScanResult => _lastScanResult;
  Map<String, dynamic>? get lastSwapResult => _lastSwapResult;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTodayMeal() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todayMeal = await _repo.getTodayMeal();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<MealTimeModel?> getMealDetail(String mealId) async {
    try {
      return await _repo.getMealDetail(mealId);
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> logMeal(String mealId,
      {String? foodItemId, int? actualPortionGram, String? notes}) async {
    try {
      await _repo.logMeal(mealId, {
        if (foodItemId != null) 'foodItemId': foodItemId,
        if (actualPortionGram != null) 'actualPortionGram': actualPortionGram,
        if (notes != null) 'notes': notes,
      });
      // refresh today's meal supaya status terupdate
      await fetchTodayMeal();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> swapMeal(String mealId, {int budgetMaxIdr = 25000}) async {
    try {
      _lastSwapResult = await _repo.swapMeal(mealId, {
        'budgetMaxIdr': budgetMaxIdr,
      });
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> replaceMeal(String mealId, Map<String, dynamic> data) async {
    try {
      await _repo.replaceMeal(mealId, data);
      await fetchTodayMeal();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget(int budgetPerDayIdr) async {
    try {
      await _repo.updateBudget(budgetPerDayIdr);
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  /// POST /meal/food-scan — kirim base64 image.
  Future<bool> foodScan({
    String? imageBase64,
    List<String>? identifiedFoods,
    List<double>? portions,
    bool persist = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _lastScanResult = await _repo.foodScan(
        imageBase64: imageBase64,
        identifiedFoods: identifiedFoods,
        portions: portions,
        persist: persist,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearScan() {
    _lastScanResult = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}
