/// Plan Provider — state management untuk plan generation & display.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/plan_repository.dart';
import 'package:heltigo/data/models/workout_model.dart';
import 'package:heltigo/data/models/meal_model.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _repo;

  bool _isLoading = false;
  bool _isGenerating = false;
  WorkoutPlanModel? _workoutPlan;
  MealPlanModel? _mealPlan;
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _replanResult;
  String? _errorMessage;

  PlanProvider(this._repo);

  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  WorkoutPlanModel? get workoutPlan => _workoutPlan;
  MealPlanModel? get mealPlan => _mealPlan;
  List<Map<String, dynamic>> get history => _history;
  Map<String, dynamic>? get replanResult => _replanResult;
  String? get errorMessage => _errorMessage;

  Future<bool> generatePlan() async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repo.generatePlan();
      _workoutPlan = result.workout;
      _mealPlan = result.meal;
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchActivePlan() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _repo.getActivePlan();
      _workoutPlan = result.workout;
      _mealPlan = result.meal;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    try {
      _history = await _repo.getPlanHistory();
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<bool> requestReplan({bool applyImmediately = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _replanResult =
          await _repo.requestReplan(applyImmediately: applyImmediately);
      if (applyImmediately) {
        // Plan baru sudah diregenerate; refresh active.
        await fetchActivePlan();
      }
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

  Future<void> replanSkip() async {
    try {
      await _repo.replanSkip();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}
