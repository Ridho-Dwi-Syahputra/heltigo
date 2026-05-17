/// Progress models — daily/weekly/streak/badges sesuai backend.
class DailyProgressModel {
  final DateTime? date;
  final bool workoutCompleted;
  final String? workoutSessionId;
  final int mealsLoggedCount;
  final int mealsTotal;
  final int waterGlasses;
  final int waterTarget;
  final String? mood;
  final int? dailyScore;
  final int caloriesConsumed;
  final int caloriesBurned;

  DailyProgressModel({
    this.date,
    this.workoutCompleted = false,
    this.workoutSessionId,
    this.mealsLoggedCount = 0,
    this.mealsTotal = 3,
    this.waterGlasses = 0,
    this.waterTarget = 8,
    this.mood,
    this.dailyScore,
    this.caloriesConsumed = 0,
    this.caloriesBurned = 0,
  });

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) {
    return DailyProgressModel(
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      workoutCompleted: json['workoutCompleted'] as bool? ?? false,
      workoutSessionId: json['workoutSessionId']?.toString(),
      mealsLoggedCount: (json['mealsLoggedCount'] as num?)?.toInt() ?? 0,
      mealsTotal: (json['mealsTotal'] as num?)?.toInt() ?? 3,
      waterGlasses: (json['waterGlasses'] as num?)?.toInt() ?? 0,
      waterTarget: (json['waterTarget'] as num?)?.toInt() ?? 8,
      mood: json['mood'] as String?,
      dailyScore: (json['dailyScore'] as num?)?.toInt(),
      caloriesConsumed: (json['caloriesConsumed'] as num?)?.toInt() ?? 0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt() ?? 0,
    );
  }
}

class WeeklyProgressModel {
  final DateTime? since;
  final int workoutsCompleted;
  final int mealsLogged;
  final int activeDays;
  final int avgWaterGlasses;
  final int totalCaloriesIn;
  final int totalCaloriesOut;
  final int weeklyScore;
  final List<DailyProgressModel> dailyBreakdown;

  WeeklyProgressModel({
    this.since,
    this.workoutsCompleted = 0,
    this.mealsLogged = 0,
    this.activeDays = 0,
    this.avgWaterGlasses = 0,
    this.totalCaloriesIn = 0,
    this.totalCaloriesOut = 0,
    this.weeklyScore = 0,
    this.dailyBreakdown = const [],
  });

  factory WeeklyProgressModel.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressModel(
      since: json['since'] != null
          ? DateTime.tryParse(json['since'].toString())
          : null,
      workoutsCompleted: (json['workoutsCompleted'] as num?)?.toInt() ?? 0,
      mealsLogged: (json['mealsLogged'] as num?)?.toInt() ?? 0,
      activeDays: (json['activeDays'] as num?)?.toInt() ?? 0,
      avgWaterGlasses: (json['avgWaterGlasses'] as num?)?.toInt() ?? 0,
      totalCaloriesIn: (json['totalCaloriesIn'] as num?)?.toInt() ?? 0,
      totalCaloriesOut: (json['totalCaloriesOut'] as num?)?.toInt() ?? 0,
      weeklyScore: (json['weeklyScore'] as num?)?.toInt() ?? 0,
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>?)
              ?.map((e) =>
                  DailyProgressModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class StreakModel {
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDate;
  final List<String> activeDates;

  StreakModel({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
    this.activeDates = const [],
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.tryParse(json['lastActiveDate'].toString())
          : null,
      activeDates: (json['activeDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
