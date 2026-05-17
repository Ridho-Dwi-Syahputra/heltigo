/// Plan Repository — wrap PlanService dengan unwrap envelope `data` jika ada.
import 'package:heltigo/data/services/plan_service.dart';
import 'package:heltigo/data/models/workout_model.dart';
import 'package:heltigo/data/models/meal_model.dart';

abstract class PlanRepository {
  Future<({WorkoutPlanModel? workout, MealPlanModel? meal})> generatePlan();
  Future<({WorkoutPlanModel? workout, MealPlanModel? meal})> getActivePlan();
  Future<List<Map<String, dynamic>>> getPlanHistory();
  Future<Map<String, dynamic>> requestReplan({bool applyImmediately = false});
  Future<void> replanSkip();
}

Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
  // Untuk endpoint generate & replan, backend bungkus `{ data: ... }`.
  final inner = json['data'];
  return inner is Map<String, dynamic> ? inner : json;
}

class PlanRepositoryImpl implements PlanRepository {
  final PlanService _service;

  PlanRepositoryImpl(this._service);

  @override
  Future<({WorkoutPlanModel? workout, MealPlanModel? meal})>
      generatePlan() async {
    final json = _unwrap(await _service.generatePlan());
    return _parsePlanPair(json);
  }

  @override
  Future<({WorkoutPlanModel? workout, MealPlanModel? meal})>
      getActivePlan() async {
    final json = await _service.getActivePlan();
    return _parsePlanPair(json);
  }

  ({WorkoutPlanModel? workout, MealPlanModel? meal}) _parsePlanPair(
      Map<String, dynamic> json) {
    final wp = json['workoutPlan'];
    final mp = json['mealPlan'];
    return (
      workout: wp is Map<String, dynamic> ? WorkoutPlanModel.fromJson(wp) : null,
      meal: mp is Map<String, dynamic> ? MealPlanModel.fromJson(mp) : null,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPlanHistory() async {
    final json = await _service.getPlanHistory();
    final plans = json['plans'];
    if (plans is List) {
      return plans
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> requestReplan(
          {bool applyImmediately = false}) async =>
      _unwrap(await _service.requestReplan(applyImmediately: applyImmediately));

  @override
  Future<void> replanSkip() => _service.replanSkip();
}
