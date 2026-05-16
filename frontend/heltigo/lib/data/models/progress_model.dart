/// Progress model — data progress harian dan mingguan
/// Sumber: docs/backend/03_DATABASE_SCHEMA.md (tabel DailyLog, WeeklyProgress)
class ProgressModel {
  final int currentStreak;
  final int bestStreak;
  final double weeklyCompliancePercent;
  final int workoutsCompleted;
  final int workoutsTotal;
  final int mealsLogged;
  final int mealsTotal;
  final List<DailyScoreModel> dailyScores;

  ProgressModel({
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyCompliancePercent,
    required this.workoutsCompleted,
    required this.workoutsTotal,
    required this.mealsLogged,
    required this.mealsTotal,
    required this.dailyScores,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      weeklyCompliancePercent:
          (json['weeklyCompliancePercent'] as num?)?.toDouble() ?? 0,
      workoutsCompleted: json['workoutsCompleted'] as int? ?? 0,
      workoutsTotal: json['workoutsTotal'] as int? ?? 0,
      mealsLogged: json['mealsLogged'] as int? ?? 0,
      mealsTotal: json['mealsTotal'] as int? ?? 0,
      dailyScores: (json['dailyScores'] as List<dynamic>?)
              ?.map(
                  (e) => DailyScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DailyScoreModel {
  final DateTime date;
  final double score;
  final String mood;

  DailyScoreModel({
    required this.date,
    required this.score,
    required this.mood,
  });

  factory DailyScoreModel.fromJson(Map<String, dynamic> json) {
    return DailyScoreModel(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      mood: json['mood'] as String? ?? 'neutral',
    );
  }
}
