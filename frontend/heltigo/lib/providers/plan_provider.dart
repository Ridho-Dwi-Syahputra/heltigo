/// Plan Provider — state management untuk plan generation & management
/// Sumber: docs/frontend/06_STATE_MANAGEMENT.md
import 'package:flutter/material.dart';
import 'package:heltigo/data/repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _planRepository;

  bool _isLoading = false;
  bool _isGenerating = false;
  Map<String, dynamic>? _activePlan;
  String? _errorMessage;

  PlanProvider(this._planRepository);

  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  Map<String, dynamic>? get activePlan => _activePlan;
  String? get errorMessage => _errorMessage;

  /// Generate rencana baru dari ML service
  Future<bool> generatePlan() async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _activePlan = await _planRepository.generatePlan();
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch rencana aktif saat ini
  Future<void> fetchActivePlan() async {
    _isLoading = true;
    notifyListeners();
    try {
      _activePlan = await _planRepository.getActivePlan();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
