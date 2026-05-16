/// Progress Repository — abstraksi akses data progress & badges
/// Sumber: docs/frontend/02_PROJECT_STRUCTURE.md
import 'package:heltigo/data/services/progress_service.dart';

abstract class ProgressRepository {
  Future<Map<String, dynamic>> getWeeklyProgress();
  Future<Map<String, dynamic>> getDailyProgress();
  Future<Map<String, dynamic>> getStreak();
  Future<Map<String, dynamic>> getBadges();
}

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressService _progressService;

  ProgressRepositoryImpl(this._progressService);

  @override
  Future<Map<String, dynamic>> getWeeklyProgress() =>
      _progressService.getWeeklyProgress();

  @override
  Future<Map<String, dynamic>> getDailyProgress() =>
      _progressService.getDailyProgress();

  @override
  Future<Map<String, dynamic>> getStreak() => _progressService.getStreak();

  @override
  Future<Map<String, dynamic>> getBadges() => _progressService.getBadges();
}
