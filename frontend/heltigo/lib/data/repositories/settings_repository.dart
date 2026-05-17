/// Settings Repository.
import 'package:heltigo/data/services/settings_service.dart';
import 'package:heltigo/data/models/settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel> getSettings();
  Future<SettingsModel> updateSettings(Map<String, dynamic> data);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsService _service;

  SettingsRepositoryImpl(this._service);

  @override
  Future<SettingsModel> getSettings() async {
    final json = await _service.getSettings();
    final inner = (json['settings'] ?? json) as Map<String, dynamic>;
    return SettingsModel.fromJson(inner);
  }

  @override
  Future<SettingsModel> updateSettings(Map<String, dynamic> data) async {
    final json = await _service.updateSettings(data);
    final inner = (json['settings'] ?? json) as Map<String, dynamic>;
    return SettingsModel.fromJson(inner);
  }
}
