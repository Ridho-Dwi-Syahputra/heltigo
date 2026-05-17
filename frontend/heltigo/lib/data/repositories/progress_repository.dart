/// Progress Repository — wrap ProgressService dengan parsing model.
import 'package:heltigo/data/services/progress_service.dart';
import 'package:heltigo/data/models/progress_model.dart';
import 'package:heltigo/data/models/badge_model.dart';

abstract class ProgressRepository {
  Future<DailyProgressModel> getDailyProgress({String? date});
  Future<WeeklyProgressModel> getWeeklyProgress();
  Future<Map<String, dynamic>> getWeeklyReview();
  Future<StreakModel> getStreak();
  Future<List<BadgeModel>> getBadges();
  Future<BadgeModel> getBadgeDetail(String code);
  Future<Map<String, dynamic>> updateWater({int? glasses, int? delta});
  Future<Map<String, dynamic>> logMood(String mood);
}

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressService _service;

  ProgressRepositoryImpl(this._service);

  @override
  Future<DailyProgressModel> getDailyProgress({String? date}) async {
    final json = await _service.getDailyProgress(date: date);
    return DailyProgressModel.fromJson(json);
  }

  @override
  Future<WeeklyProgressModel> getWeeklyProgress() async {
    final json = await _service.getWeeklyProgress();
    return WeeklyProgressModel.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> getWeeklyReview() =>
      _service.getWeeklyReview();

  @override
  Future<StreakModel> getStreak() async {
    final json = await _service.getStreak();
    return StreakModel.fromJson(json);
  }

  @override
  Future<List<BadgeModel>> getBadges() async {
    final json = await _service.getBadges();
    final list = json['badges'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(BadgeModel.fromJson)
          .toList(growable: false);
    }
    return [];
  }

  @override
  Future<BadgeModel> getBadgeDetail(String code) async {
    final json = await _service.getBadgeDetail(code);
    final badge = (json['badge'] ?? json) as Map<String, dynamic>;
    return BadgeModel.fromJson(badge);
  }

  @override
  Future<Map<String, dynamic>> updateWater({int? glasses, int? delta}) =>
      _service.updateWater(glasses: glasses, delta: delta);

  @override
  Future<Map<String, dynamic>> logMood(String mood) => _service.logMood(mood);
}
