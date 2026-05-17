/// ProfileDraftProvider — menyimpan data wizard 7 langkah onboarding.
/// Setiap step memanggil `updateXxx(...)` lalu pindah ke step berikutnya.
/// Di step terakhir, panggil [toPayload] dan kirim ke
/// `ProfileProvider.createHealthProfile(payload)`.
import 'package:flutter/foundation.dart';

class ProfileDraft {
  // Step 1 — Basic Info
  String? name;
  int? age;
  String? gender; // M / F / OTHER

  // Step 2 — Physical
  double? heightCm;
  double? weightKg;
  double? targetWeightKg;

  // Step 4 — Goal
  String? goal; // WEIGHT_LOSS / MUSCLE_GAIN / MAINTENANCE / PERFORMANCE

  // Step 5 — Conditions
  List<String> healthConditions = [];
  List<String> allergies = [];

  // Step 6 — Fitness Level + Mode
  String? fitnessLevel; // BEGINNER / INTERMEDIATE / ADVANCED
  String? workoutMode; // HOME / GYM / HYBRID
  int? availableDaysPerWeek;
  int? sessionDurationMin;
  List<String> preferredEquipment = [];

  // Step 7 — Preferences
  double? budgetPerDayIdr;
  List<String> dietaryRestrictions = [];

  Map<String, dynamic> toPayload() => {
        'age': age ?? 25,
        'gender': gender ?? 'OTHER',
        'heightCm': heightCm ?? 165,
        'weightKg': weightKg ?? 60,
        'startWeightKg': weightKg ?? 60,
        if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
        'fitnessLevel': fitnessLevel ?? 'BEGINNER',
        'goal': goal ?? 'MAINTENANCE',
        'healthConditions': healthConditions,
        'allergies': allergies,
        'dietaryRestrictions': dietaryRestrictions,
        'preferredEquipment': preferredEquipment,
        'availableDaysPerWeek': availableDaysPerWeek ?? 3,
        'sessionDurationMin': sessionDurationMin ?? 30,
        'workoutMode': workoutMode ?? 'HOME',
        'budgetPerDayIdr': budgetPerDayIdr ?? 35000,
      };
}

class ProfileDraftProvider extends ChangeNotifier {
  final ProfileDraft _draft = ProfileDraft();

  ProfileDraft get draft => _draft;

  void updateBasicInfo({String? name, int? age, String? gender}) {
    if (name != null) _draft.name = name;
    if (age != null) _draft.age = age;
    if (gender != null) _draft.gender = gender;
    notifyListeners();
  }

  void updatePhysical({
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
  }) {
    if (heightCm != null) _draft.heightCm = heightCm;
    if (weightKg != null) _draft.weightKg = weightKg;
    if (targetWeightKg != null) _draft.targetWeightKg = targetWeightKg;
    notifyListeners();
  }

  void updateGoal(String goal) {
    _draft.goal = goal;
    notifyListeners();
  }

  void updateConditions({
    List<String>? conditions,
    List<String>? allergies,
  }) {
    if (conditions != null) _draft.healthConditions = conditions;
    if (allergies != null) _draft.allergies = allergies;
    notifyListeners();
  }

  void updateFitness({
    String? level,
    String? mode,
    int? daysPerWeek,
    int? sessionMin,
    List<String>? equipment,
  }) {
    if (level != null) _draft.fitnessLevel = level;
    if (mode != null) _draft.workoutMode = mode;
    if (daysPerWeek != null) _draft.availableDaysPerWeek = daysPerWeek;
    if (sessionMin != null) _draft.sessionDurationMin = sessionMin;
    if (equipment != null) _draft.preferredEquipment = equipment;
    notifyListeners();
  }

  void updatePreferences({
    double? budgetPerDayIdr,
    List<String>? dietaryRestrictions,
  }) {
    if (budgetPerDayIdr != null) _draft.budgetPerDayIdr = budgetPerDayIdr;
    if (dietaryRestrictions != null) {
      _draft.dietaryRestrictions = dietaryRestrictions;
    }
    notifyListeners();
  }

  // BMI/BMR/TDEE helpers — dihitung lokal dari draft (tidak perlu API).
  double? get bmi {
    final w = _draft.weightKg;
    final h = _draft.heightCm;
    if (w == null || h == null || h == 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }

  String get bmiCategory {
    final v = bmi;
    if (v == null) return '-';
    if (v < 18.5) return 'Kurus';
    if (v < 25) return 'Normal';
    if (v < 30) return 'Berlebih';
    return 'Obesitas';
  }

  double? get bmr {
    final w = _draft.weightKg;
    final h = _draft.heightCm;
    final a = _draft.age;
    final g = _draft.gender;
    if (w == null || h == null || a == null) return null;
    final base = 10 * w + 6.25 * h - 5 * a;
    return g == 'M' ? base + 5 : base - 161;
  }

  double? get tdee {
    final base = bmr;
    if (base == null) return null;
    const mults = {
      'BEGINNER': 1.2,
      'INTERMEDIATE': 1.55,
      'ADVANCED': 1.725,
    };
    return base * (mults[_draft.fitnessLevel] ?? 1.2);
  }

  void reset() {
    _draft.name = null;
    _draft.age = null;
    _draft.gender = null;
    _draft.heightCm = null;
    _draft.weightKg = null;
    _draft.targetWeightKg = null;
    _draft.goal = null;
    _draft.healthConditions = [];
    _draft.allergies = [];
    _draft.fitnessLevel = null;
    _draft.workoutMode = null;
    _draft.availableDaysPerWeek = null;
    _draft.sessionDurationMin = null;
    _draft.preferredEquipment = [];
    _draft.budgetPerDayIdr = null;
    _draft.dietaryRestrictions = [];
    notifyListeners();
  }
}
