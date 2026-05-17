/// Settings model — match dengan backend `settings` table.
class SettingsModel {
  final String? id;
  final String theme; // LIGHT / DARK / SYSTEM
  final String language; // id / en
  final String timezone;
  final bool notificationsEnabled;
  final String? dailyReminderTime; // HH:mm:ss
  final String? workoutReminderTime;
  final String? mealReminderTime;

  SettingsModel({
    this.id,
    this.theme = 'DARK',
    this.language = 'id',
    this.timezone = 'Asia/Jakarta',
    this.notificationsEnabled = true,
    this.dailyReminderTime,
    this.workoutReminderTime,
    this.mealReminderTime,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id']?.toString(),
      theme: (json['theme'] ?? 'DARK').toString(),
      language: (json['language'] ?? 'id').toString(),
      timezone: (json['timezone'] ?? 'Asia/Jakarta').toString(),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminderTime: json['dailyReminderTime']?.toString(),
      workoutReminderTime: json['workoutReminderTime']?.toString(),
      mealReminderTime: json['mealReminderTime']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'theme': theme,
        'language': language,
        'timezone': timezone,
        'notificationsEnabled': notificationsEnabled,
        if (dailyReminderTime != null) 'dailyReminderTime': dailyReminderTime,
        if (workoutReminderTime != null)
          'workoutReminderTime': workoutReminderTime,
        if (mealReminderTime != null) 'mealReminderTime': mealReminderTime,
      };
}
