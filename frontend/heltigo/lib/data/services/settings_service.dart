/// Settings Service — komunikasi API untuk user settings.
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/data/api/endpoints.dart';

class SettingsService {
  final ApiService _apiService;

  SettingsService(this._apiService);

  Future<Map<String, dynamic>> getSettings() async {
    final res = await _apiService.get(ApiEndpoints.settings);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final res = await _apiService.put(ApiEndpoints.settings, data: data);
    return res.data as Map<String, dynamic>;
  }
}
