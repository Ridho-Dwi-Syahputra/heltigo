/// Profile Repository — wrap ProfileService dengan parsing flat response.
import 'package:heltigo/data/services/profile_service.dart';
import 'package:heltigo/data/models/user_model.dart';
import 'package:heltigo/data/models/health_profile_model.dart';

abstract class ProfileRepository {
  Future<({UserModel user, HealthProfileModel? healthProfile})> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<UserModel> updateAvatar(String avatarUrl);
  Future<HealthProfileModel> createHealthProfile(Map<String, dynamic> data);
  Future<HealthProfileModel> updateHealthProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getCurrentMetrics();
  Future<Map<String, dynamic>> logHealthMetric({double? weightKg});
  Future<Map<String, dynamic>> getMetricsHistory({int days = 30});
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _service;

  ProfileRepositoryImpl(this._service);

  @override
  Future<({UserModel user, HealthProfileModel? healthProfile})>
      getProfile() async {
    final json = await _service.getProfile();
    final user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    final hpJson = json['healthProfile'];
    final hp = hpJson is Map<String, dynamic>
        ? HealthProfileModel.fromJson(hpJson)
        : null;
    return (user: user, healthProfile: hp);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final json = await _service.updateProfile(data);
    final userJson = (json['user'] ?? json) as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<UserModel> updateAvatar(String avatarUrl) async {
    final json = await _service.updateAvatar(avatarUrl);
    final userJson = (json['user'] ?? json) as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<HealthProfileModel> createHealthProfile(
      Map<String, dynamic> data) async {
    final json = await _service.createHealthProfile(data);
    final hpJson =
        (json['healthProfile'] ?? json) as Map<String, dynamic>;
    return HealthProfileModel.fromJson(hpJson);
  }

  @override
  Future<HealthProfileModel> updateHealthProfile(
      Map<String, dynamic> data) async {
    final json = await _service.updateHealthProfile(data);
    final hpJson =
        (json['healthProfile'] ?? json) as Map<String, dynamic>;
    return HealthProfileModel.fromJson(hpJson);
  }

  @override
  Future<Map<String, dynamic>> getCurrentMetrics() =>
      _service.getHealthMetrics();

  @override
  Future<Map<String, dynamic>> logHealthMetric({double? weightKg}) =>
      _service.saveHealthMetrics(
        weightKg != null ? {'weightKg': weightKg} : {},
      );

  @override
  Future<Map<String, dynamic>> getMetricsHistory({int days = 30}) =>
      _service.getHealthMetricsHistory(days: days);
}
