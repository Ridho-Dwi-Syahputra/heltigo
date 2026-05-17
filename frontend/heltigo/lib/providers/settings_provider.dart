/// Settings Provider — theme/language/timezone/reminders.
import 'package:flutter/material.dart';
import 'package:heltigo/data/api/api_exception.dart';
import 'package:heltigo/data/repositories/settings_repository.dart';
import 'package:heltigo/data/models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo;

  SettingsModel? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  SettingsProvider(this._repo);

  SettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _repo.getSettings();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _msg(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSettings(Map<String, dynamic> data) async {
    try {
      _settings = await _repo.updateSettings(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _msg(e);
      notifyListeners();
      return false;
    }
  }

  String _msg(Object e) => e is ApiException ? e.message : e.toString();
}
