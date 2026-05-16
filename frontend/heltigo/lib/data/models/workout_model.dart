/// Workout plan model — rencana latihan dari ML service
/// Sumber: docs/backend/03_DATABASE_SCHEMA.md (tabel WorkoutPlan, WorkoutDay, Exercise)
class WorkoutPlanModel {
  final String id;
  final String planId;
  final List<WorkoutDayModel> days;

  WorkoutPlanModel({
    required this.id,
    required this.planId,
    required this.days,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanModel(
      id: json['id'] as String,
      planId: json['planId'] as String,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => WorkoutDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WorkoutDayModel {
  final String id;
  final int dayNumber;
  final String workoutType;
  final String intensity;
  final int durationMin;
  final List<ExerciseModel> exercises;
  final bool isCompleted;

  WorkoutDayModel({
    required this.id,
    required this.dayNumber,
    required this.workoutType,
    required this.intensity,
    required this.durationMin,
    required this.exercises,
    this.isCompleted = false,
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDayModel(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      workoutType: json['workoutType'] as String,
      intensity: json['intensity'] as String,
      durationMin: json['durationMin'] as int,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int? durationSec;
  final String? notes;
  final bool isCompleted;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.durationSec,
    this.notes,
    this.isCompleted = false,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      durationSec: json['durationSec'] as int?,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
