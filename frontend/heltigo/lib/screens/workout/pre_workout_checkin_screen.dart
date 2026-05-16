/// S-19: Pre-Workout Check-in — input mood, energy, dan kualitas tidur
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-19
///
/// Sections:
/// 1. AppBar + back
/// 2. Title + subtitle
/// 3. Mood selector (5 emoji-icon)
/// 4. Energy selector (5 battery-icon)
/// 5. Sleep band chips (5 options)
/// 6. AI Preview card (muncul saat 3 input terisi)
/// 7. Sticky bottom: PrimaryButton "Ayo Mulai!"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';
import '../../widgets/workout/mood_selector.dart';

class PreWorkoutCheckInScreen extends StatefulWidget {
  final String workoutId;

  const PreWorkoutCheckInScreen({super.key, required this.workoutId});

  @override
  State<PreWorkoutCheckInScreen> createState() =>
      _PreWorkoutCheckInScreenState();
}

class _PreWorkoutCheckInScreenState extends State<PreWorkoutCheckInScreen> {
  int _moodIndex = -1;
  int _energyIndex = -1;
  int _sleepIndex = -1;

  static const List<IconData> _moodIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];
  static const List<String> _moodLabels = [
    'Buruk',
    'Kurang',
    'Biasa',
    'Bagus',
    'Prima',
  ];

  static const List<IconData> _energyIcons = [
    Icons.battery_0_bar,
    Icons.battery_2_bar,
    Icons.battery_4_bar,
    Icons.battery_5_bar,
    Icons.battery_charging_full,
  ];
  static const List<String> _energyLabels = [
    'Lelah',
    'Lemas',
    'Cukup',
    'Segar',
    'Penuh',
  ];

  static const List<String> _sleepBands = [
    '<5 jam',
    '5-6 jam',
    '6-7 jam',
    '7-8 jam',
    '>8 jam',
  ];

  bool get _isComplete =>
      _moodIndex >= 0 && _energyIndex >= 0 && _sleepIndex >= 0;

  /// Hitung delta intensitas (-30% s/d +20%) berdasarkan input
  int get _aiAdjustment {
    if (!_isComplete) return 0;
    // Mood/energy 0-4 → -10..+10
    final moodScore = (_moodIndex - 2) * 5;
    final energyScore = (_energyIndex - 2) * 5;
    // Sleep 0=<5, 4=>8 → -5..+5
    final sleepScore = (_sleepIndex - 2) * 2;
    final total = moodScore + energyScore + sleepScore;
    return total.clamp(-30, 20);
  }

  String get _aiSummary {
    final delta = _aiAdjustment;
    if (delta <= -20) {
      return 'Volume dikurangi $delta% — fokus mobility & tempo lambat.';
    }
    if (delta < 0) {
      return 'Volume dikurangi ${delta.abs()}% — tetap perhatikan teknik.';
    }
    if (delta == 0) {
      return 'Intensitas dipertahankan — perform sesuai rencana.';
    }
    if (delta < 15) {
      return 'Intensitas dinaikkan +$delta% — kondisi prima!';
    }
    return 'Intensitas penuh +$delta% — push your limit!';
  }

  Color get _aiColor {
    final delta = _aiAdjustment;
    if (delta < -10) return AppColors.warning;
    if (delta > 10) return AppColors.success;
    return AppColors.primary;
  }

  void _onStart() {
    // TODO: integrate dengan WorkoutProvider.checkin()
    context.push('/workout/active/${widget.workoutId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text('Check-in', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.sm,
                ),
                children: [
                  // ─── Title ───
                  Text(
                    'Bagaimana kondisimu?',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'AI menyesuaikan intensitas latihanmu berdasarkan jawaban ini.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // ─── Mood ───
                  _SectionLabel('Suasana Hati'),
                  const SizedBox(height: AppDimensions.sm),
                  MoodSelector(
                    selectedIndex: _moodIndex,
                    onChanged: (i) => setState(() => _moodIndex = i),
                    icons: _moodIcons,
                    labels: _moodLabels,
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── Energy ───
                  _SectionLabel('Tingkat Energi'),
                  const SizedBox(height: AppDimensions.sm),
                  MoodSelector(
                    selectedIndex: _energyIndex,
                    onChanged: (i) => setState(() => _energyIndex = i),
                    icons: _energyIcons,
                    labels: _energyLabels,
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── Sleep ───
                  _SectionLabel('Kualitas Tidur Tadi Malam'),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: List.generate(_sleepBands.length, (i) {
                      final isActive = i == _sleepIndex;
                      return InkWell(
                        onTap: () => setState(() => _sleepIndex = i),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                            vertical: AppDimensions.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bedtime_outlined,
                                size: 14,
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _sleepBands[i],
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isActive
                                      ? AppColors.textOnPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // ─── AI Preview (saat 3 input terisi) ───
                  if (_isComplete)
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.base),
                      decoration: BoxDecoration(
                        color: _aiColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusCard),
                        border: Border.all(
                          color: _aiColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _aiColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: _aiColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'AI MENYESUAIKAN INTENSITAS',
                                  style: AppTextStyles.overline.copyWith(
                                    color: _aiColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _aiSummary,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ─── Sticky bottom ───
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base +
                    MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: _isComplete ? 'Ayo Mulai!' : 'Lengkapi Dulu',
                icon: Icons.play_arrow_rounded,
                onPressed: _isComplete ? _onStart : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;

  // ignore: unused_element_parameter
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
