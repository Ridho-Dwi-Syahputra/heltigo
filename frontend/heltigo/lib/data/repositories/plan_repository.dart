/// Plan Repository — abstraksi akses data plan
/// Sumber: docs/frontend/02_PROJECT_STRUCTURE.md
import 'package:heltigo/data/services/plan_service.dart';

abstract class PlanRepository {
  Future<Map<String, dynamic>> generatePlan();
  Future<Map<String, dynamic>> getActivePlan();
  Future<Map<String, dynamic>> getPlanHistory();
  Future<Map<String, dynamic>> requestReplan();
}

class PlanRepositoryImpl implements PlanRepository {
  final PlanService _planService;

  PlanRepositoryImpl(this._planService);

  @override
  Future<Map<String, dynamic>> generatePlan() =>
      _planService.generatePlan();

  @override
  Future<Map<String, dynamic>> getActivePlan() =>
      _planService.getActivePlan();

  @override
  Future<Map<String, dynamic>> getPlanHistory() =>
      _planService.getPlanHistory();

  @override
  Future<Map<String, dynamic>> requestReplan() =>
      _planService.requestReplan();
}
