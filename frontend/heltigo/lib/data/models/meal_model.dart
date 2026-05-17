/// Meal plan model — match dengan backend `meal_plans` → `meal_days` →
/// `meal_times` → `food_items`.
class MealPlanModel {
  final String id;
  final DateTime? startDate;
  final DateTime? endDate;
  final int targetCaloriesPerDay;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;
  final double budgetPerDayIdr;
  final List<MealDayModel> days;

  MealPlanModel({
    required this.id,
    this.startDate,
    this.endDate,
    this.targetCaloriesPerDay = 0,
    this.targetProteinG = 0,
    this.targetCarbsG = 0,
    this.targetFatG = 0,
    this.budgetPerDayIdr = 0,
    required this.days,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'].toString(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      targetCaloriesPerDay:
          (json['targetCaloriesPerDay'] as num?)?.toInt() ?? 0,
      targetProteinG: (json['targetProteinG'] as num?)?.toInt() ?? 0,
      targetCarbsG: (json['targetCarbsG'] as num?)?.toInt() ?? 0,
      targetFatG: (json['targetFatG'] as num?)?.toInt() ?? 0,
      budgetPerDayIdr: (json['budgetPerDayIdr'] as num?)?.toDouble() ?? 0,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => MealDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}

class MealDayModel {
  final String id;
  final int dayNumber;
  final DateTime? date;
  final int? totalCalories;
  final double? totalProteinG;
  final double? totalCarbsG;
  final double? totalFatG;
  final double? totalCostIdr;
  final List<MealTimeModel> meals;

  MealDayModel({
    required this.id,
    required this.dayNumber,
    this.date,
    this.totalCalories,
    this.totalProteinG,
    this.totalCarbsG,
    this.totalFatG,
    this.totalCostIdr,
    required this.meals,
  });

  factory MealDayModel.fromJson(Map<String, dynamic> json) {
    return MealDayModel(
      id: json['id'].toString(),
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      totalCalories: (json['totalCalories'] as num?)?.toInt(),
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble(),
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble(),
      totalFatG: (json['totalFatG'] as num?)?.toDouble(),
      totalCostIdr: (json['totalCostIdr'] as num?)?.toDouble(),
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealTimeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MealTimeModel {
  final String id;
  final String mealType; // BREAKFAST/LUNCH/DINNER/SNACK
  final String? scheduledTime;
  final bool isLogged;
  final DateTime? loggedAt;
  final int orderIndex;
  final List<FoodItemModel> foods;

  MealTimeModel({
    required this.id,
    required this.mealType,
    this.scheduledTime,
    this.isLogged = false,
    this.loggedAt,
    this.orderIndex = 0,
    required this.foods,
  });

  factory MealTimeModel.fromJson(Map<String, dynamic> json) {
    return MealTimeModel(
      id: json['id'].toString(),
      mealType: (json['mealType'] ?? 'BREAKFAST').toString(),
      scheduledTime: json['scheduledTime'] as String?,
      isLogged: json['isLogged'] as bool? ?? false,
      loggedAt: json['loggedAt'] != null
          ? DateTime.tryParse(json['loggedAt'].toString())
          : null,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      foods: (json['foods'] as List<dynamic>?)
              ?.map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FoodItemModel {
  final String id;
  final String name;
  final String portion;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double estimatedCostIdr;
  final int orderIndex;

  FoodItemModel({
    required this.id,
    required this.name,
    required this.portion,
    required this.calories,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.estimatedCostIdr = 0,
    this.orderIndex = 0,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'].toString(),
      name: (json['name'] ?? 'Food').toString(),
      portion: (json['portion'] ?? '1 porsi').toString(),
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
      fiberG: (json['fiberG'] as num?)?.toDouble() ?? 0,
      estimatedCostIdr:
          (json['estimatedCostIdr'] as num?)?.toDouble() ?? 0,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
