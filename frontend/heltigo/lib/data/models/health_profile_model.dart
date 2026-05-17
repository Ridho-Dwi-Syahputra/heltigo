/// Health profile model — match dengan backend `health_profiles` table.
/// Backend mengembalikan: BMI auto-calculated, enum values uppercase.
class HealthProfileModel {
  final String? id;
  final int age;
  final String gender; // M / F / OTHER
  final double heightCm;
  final double weightKg;
  final double? startWeightKg;
  final double? targetWeightKg;
  final String fitnessLevel; // BEGINNER / INTERMEDIATE / ADVANCED
  final String goal; // WEIGHT_LOSS / MUSCLE_GAIN / MAINTENANCE / PERFORMANCE
  final List<String> healthConditions;
  final List<String> allergies;
  final List<String> dietaryRestrictions;
  final List<String> preferredEquipment;
  final int availableDaysPerWeek;
  final int sessionDurationMin;
  final String workoutMode; // HOME / GYM / HYBRID
  final double budgetPerDayIdr;
  final double? bmi;

  HealthProfileModel({
    this.id,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.startWeightKg,
    this.targetWeightKg,
    required this.fitnessLevel,
    required this.goal,
    required this.healthConditions,
    required this.allergies,
    required this.dietaryRestrictions,
    required this.preferredEquipment,
    required this.availableDaysPerWeek,
    required this.sessionDurationMin,
    required this.workoutMode,
    required this.budgetPerDayIdr,
    this.bmi,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    return HealthProfileModel(
      id: json['id']?.toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] ?? 'OTHER').toString(),
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      startWeightKg: (json['startWeightKg'] as num?)?.toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      fitnessLevel: (json['fitnessLevel'] ?? 'BEGINNER').toString(),
      goal: (json['goal'] ?? 'MAINTENANCE').toString(),
      healthConditions: _list(json['healthConditions']),
      allergies: _list(json['allergies']),
      dietaryRestrictions: _list(json['dietaryRestrictions']),
      preferredEquipment: _list(json['preferredEquipment']),
      availableDaysPerWeek:
          (json['availableDaysPerWeek'] as num?)?.toInt() ?? 3,
      sessionDurationMin: (json['sessionDurationMin'] as num?)?.toInt() ?? 30,
      workoutMode: (json['workoutMode'] ?? 'HOME').toString(),
      budgetPerDayIdr: (json['budgetPerDayIdr'] as num?)?.toDouble() ?? 35000,
      bmi: (json['bmi'] as num?)?.toDouble(),
    );
  }

  static List<String> _list(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        if (startWeightKg != null) 'startWeightKg': startWeightKg,
        if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
        'fitnessLevel': fitnessLevel,
        'goal': goal,
        'healthConditions': healthConditions,
        'allergies': allergies,
        'dietaryRestrictions': dietaryRestrictions,
        'preferredEquipment': preferredEquipment,
        'availableDaysPerWeek': availableDaysPerWeek,
        'sessionDurationMin': sessionDurationMin,
        'workoutMode': workoutMode,
        'budgetPerDayIdr': budgetPerDayIdr,
      };
}
