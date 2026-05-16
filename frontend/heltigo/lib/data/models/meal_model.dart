/// Meal plan model — rencana makan dari ML service
/// Sumber: docs/backend/03_DATABASE_SCHEMA.md (tabel MealPlan, MealDay, MealItem)
class MealPlanModel {
  final String id;
  final String planId;
  final List<MealDayModel> days;

  MealPlanModel({
    required this.id,
    required this.planId,
    required this.days,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      planId: json['planId'] as String,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => MealDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MealDayModel {
  final String id;
  final int dayNumber;
  final double totalCalories;
  final double totalProtein;
  final double totalCost;
  final List<MealItemModel> meals;

  MealDayModel({
    required this.id,
    required this.dayNumber,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCost,
    required this.meals,
  });

  factory MealDayModel.fromJson(Map<String, dynamic> json) {
    return MealDayModel(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MealItemModel {
  final String id;
  final String name;
  final String mealTime; // breakfast, lunch, dinner, snack
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double estimatedCost;
  final bool isLogged;

  MealItemModel({
    required this.id,
    required this.name,
    required this.mealTime,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.estimatedCost,
    this.isLogged = false,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      mealTime: json['mealTime'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      isLogged: json['isLogged'] as bool? ?? false,
    );
  }
}
