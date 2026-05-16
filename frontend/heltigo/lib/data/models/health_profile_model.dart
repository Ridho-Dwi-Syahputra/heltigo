/// Health profile model — profil kesehatan pengguna
/// Sumber: docs/backend/03_DATABASE_SCHEMA.md (tabel HealthProfile)
class HealthProfileModel {
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessLevel;
  final String? goal;
  final List<String>? healthConditions;
  final double? budgetPerDay;
  final int? availableDaysPerWeek;
  final int? sessionDurationMin;

  HealthProfileModel({
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.fitnessLevel,
    this.goal,
    this.healthConditions,
    this.budgetPerDay,
    this.availableDaysPerWeek,
    this.sessionDurationMin,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    return HealthProfileModel(
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      fitnessLevel: json['fitnessLevel'] as String?,
      goal: json['goal'] as String?,
      healthConditions: (json['healthConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      budgetPerDay: (json['budgetPerDay'] as num?)?.toDouble(),
      availableDaysPerWeek: json['availableDaysPerWeek'] as int?,
      sessionDurationMin: json['sessionDurationMin'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'fitnessLevel': fitnessLevel,
        'goal': goal,
        'healthConditions': healthConditions,
        'budgetPerDay': budgetPerDay,
        'availableDaysPerWeek': availableDaysPerWeek,
        'sessionDurationMin': sessionDurationMin,
      };
}
