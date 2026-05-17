/// Badge model — match dengan backend `badges` + `user_badges`.
class BadgeModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String iconName;
  final String? iconColor;
  final String category; // STREAK/MILESTONE/GOAL/SPECIAL
  final String criterionType; // STREAK/WORKOUTS_DONE/WEIGHT_LOST/MEALS_LOGGED
  final int criterionValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  BadgeModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.iconName,
    this.iconColor,
    required this.category,
    required this.criterionType,
    required this.criterionValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'].toString(),
      code: (json['code'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      iconName: (json['iconName'] ?? 'emoji_events').toString(),
      iconColor: json['iconColor'] as String?,
      category: (json['category'] ?? 'MILESTONE').toString(),
      criterionType: (json['criterionType'] ?? 'CUSTOM').toString(),
      criterionValue: (json['criterionValue'] as num?)?.toInt() ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : null,
    );
  }
}
