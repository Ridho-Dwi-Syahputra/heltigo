/// Profile Provider — state management untuk profil & health metrics
/// Sumber: docs/frontend/06_STATE_MANAGEMENT.md
import 'package:flutter/material.dart';
import 'package:heltigo/data/repositories/profile_repository.dart';
import 'package:heltigo/data/models/user_model.dart';
import 'package:heltigo/data/models/health_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  bool _isLoading = false;
  UserModel? _user;
  HealthProfileModel? _healthProfile;
  String? _errorMessage;

  ProfileProvider(this._profileRepository);

  bool get isLoading => _isLoading;
  UserModel? get user => _user;
  HealthProfileModel? get healthProfile => _healthProfile;
  String? get errorMessage => _errorMessage;

  /// Fetch user profile dari API
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _profileRepository.getProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch health metrics
  Future<void> fetchHealthMetrics() async {
    _isLoading = true;
    notifyListeners();
    try {
      _healthProfile = await _profileRepository.getHealthMetrics();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Save health metrics (setup profil baru / update)
  Future<bool> saveHealthMetrics(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _healthProfile = await _profileRepository.saveHealthMetrics(data);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
