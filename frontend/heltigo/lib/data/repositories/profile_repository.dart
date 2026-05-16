/// Profile Repository — abstraksi akses data profil & health metrics
/// Sumber: docs/frontend/02_PROJECT_STRUCTURE.md
import 'package:heltigo/data/services/profile_service.dart';
import 'package:heltigo/data/models/user_model.dart';
import 'package:heltigo/data/models/health_profile_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<HealthProfileModel> getHealthMetrics();
  Future<HealthProfileModel> saveHealthMetrics(Map<String, dynamic> data);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  @override
  Future<UserModel> getProfile() async {
    final json = await _profileService.getProfile();
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final json = await _profileService.updateProfile(data);
    return UserModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<HealthProfileModel> getHealthMetrics() async {
    final json = await _profileService.getHealthMetrics();
    return HealthProfileModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<HealthProfileModel> saveHealthMetrics(
      Map<String, dynamic> data) async {
    final json = await _profileService.saveHealthMetrics(data);
    return HealthProfileModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}
