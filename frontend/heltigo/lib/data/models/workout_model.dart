/// Workout plan model — match dengan backend `workout_plans` table.
class WorkoutPlanModel {
  final String id;
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final bool isActive;
  final List<WorkoutDayModel> days;

  WorkoutPlanModel({
    required this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.status,
    this.isActive = true,
    required this.days,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      id: json['id'].toString(),
      name: json['name'] as String?,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      status: json['status'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => WorkoutDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class WorkoutDayModel {
  final String id;
  final int dayNumber;
  final DateTime? date;
  final String workoutType; // STRENGTH/CARDIO/HIIT/FLEXIBILITY/REST
  final String? intensity; // LOW/MID/HIGH
  final String? name;
  final int? durationMin;
  final int? totalSets;
  final bool isCompleted;
  final List<ExerciseModel> exercises;

  WorkoutDayModel({
    required this.id,
    required this.dayNumber,
    this.date,
    required this.workoutType,
    this.intensity,
    this.name,
    this.durationMin,
    this.totalSets,
    this.isCompleted = false,
    required this.exercises,
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDayModel(
      id: json['id'].toString(),
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 0,
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      workoutType: (json['workoutType'] ?? 'STRENGTH').toString(),
      intensity: json['intensity'] as String?,
      name: json['name'] as String?,
      durationMin: (json['durationMin'] as num?)?.toInt(),
      totalSets: (json['totalSets'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isRestDay => workoutType == 'REST';
}

class ExerciseModel {
  final String id;
  final String name;
  final String category; // WARMUP / MAIN / COOLDOWN
  final int sets;
  final int? reps;
  final int? durationSec;
  final int restSec;
  final int orderIndex;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.sets,
    this.reps,
    this.durationSec,
    this.restSec = 60,
    this.orderIndex = 0,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'].toString(),
      name: (json['name'] ?? 'Exercise').toString(),
      category: (json['category'] ?? 'MAIN').toString(),
      sets: (json['sets'] as num?)?.toInt() ?? 1,
      reps: (json['reps'] as num?)?.toInt(),
      durationSec: (json['durationSec'] as num?)?.toInt(),
      restSec: (json['restSec'] as num?)?.toInt() ?? 60,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
