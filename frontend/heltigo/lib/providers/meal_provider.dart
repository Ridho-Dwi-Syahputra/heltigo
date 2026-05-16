/// Meal Provider — state management untuk meal plan & logging
/// Sumber: docs/frontend/06_STATE_MANAGEMENT.md
import 'package:flutter/material.dart';
import 'package:heltigo/data/repositories/meal_repository.dart';

class MealProvider extends ChangeNotifier {
  final MealRepository _mealRepository;

  bool _isLoading = false;
  Map<String, dynamic>? _todayMeal;
  String? _errorMessage;

  MealProvider(this._mealRepository);

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get todayMeal => _todayMeal;
  String? get errorMessage => _errorMessage;

  /// Fetch meal plan hari ini
  Future<void> fetchTodayMeal() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todayMeal = await _mealRepository.getTodayMeal();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Log meal sebagai dimakan
  Future<bool> logMeal(String id, Map<String, dynamic> data) async {
    try {
      await _mealRepository.logMeal(id, data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Swap meal dengan alternatif
  Future<bool> swapMeal(String id, Map<String, dynamic> data) async {
    try {
      await _mealRepository.swapMeal(id, data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
