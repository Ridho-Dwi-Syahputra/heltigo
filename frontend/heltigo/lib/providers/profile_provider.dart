/// Profile Provider — state management untuk user profile & health metrics.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/profile_repository.dart';
import 'package:heltigo/data/models/user_model.dart';
import 'package:heltigo/data/models/health_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo;

  bool _isLoading = false;
  UserModel? _user;
  HealthProfileModel? _healthProfile;
  Map<String, dynamic>? _currentMetrics;
  List<dynamic>? _metricsHistory;
  String? _errorMessage;

  ProfileProvider(this._repo);

  bool get isLoading => _isLoading;
  UserModel? get user => _user;
  HealthProfileModel? get healthProfile => _healthProfile;
  Map<String, dynamic>? get currentMetrics => _currentMetrics;
  List<dynamic>? get metricsHistory => _metricsHistory;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _repo.getProfile();
      _user = result.user;
      _healthProfile = result.healthProfile;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    try {
      _user = await _repo.updateProfile({
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  /// Submit onboarding payload (POST /user/health-profile).
  Future<bool> createHealthProfile(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _healthProfile = await _repo.createHealthProfile(payload);
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

  Future<bool> updateHealthProfile(Map<String, dynamic> payload) async {
    try {
      _healthProfile = await _repo.updateHealthProfile(payload);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchHealthMetrics() async {
    try {
      _currentMetrics = await _repo.getCurrentMetrics();
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  Future<bool> logHealthMetric({double? weightKg}) async {
    try {
      await _repo.logHealthMetric(weightKg: weightKg);
      await fetchProfile();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMetricsHistory({int days = 30}) async {
    try {
      final json = await _repo.getMetricsHistory(days: days);
      _metricsHistory = json['history'] as List<dynamic>?;
      notifyListeners();
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
    }
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}
