/// S-20: Active Workout Screen — sesi latihan aktif dengan timer
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-20
///
/// Layout:
/// 1. AppBar dengan progress + "Selesai Lebih Awal"
/// 2. Total timer (count up) + label
/// 3. Exercise card besar (nama, set, reps)
/// 4. Rest timer card (saat istirahat)
/// 5. Kontrol: prev / pause / next
/// 6. Bottom: progress bar "Exercise X / Y"
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/workout/workout_timer_display.dart';

class _ExerciseStep {
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;

  const _ExerciseStep({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });
}

class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({super.key, required this.workoutId});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  // ─── Mock workout steps ───
  static const List<_ExerciseStep> _steps = [
    _ExerciseStep(name: 'Jumping Jacks', sets: 1, reps: 30, restSeconds: 30),
    _ExerciseStep(name: 'Push-Up', sets: 4, reps: 12, restSeconds: 60),
    _ExerciseStep(name: 'Diamond Push-Up', sets: 3, reps: 10, restSeconds: 60),
    _ExerciseStep(name: 'Plank', sets: 3, reps: 30, restSeconds: 45),
    _ExerciseStep(name: 'Mountain Climber', sets: 3, reps: 20, restSeconds: 45),
    _ExerciseStep(name: 'Russian Twist', sets: 3, reps: 20, restSeconds: 45),
    _ExerciseStep(name: 'Cobra Stretch', sets: 1, reps: 30, restSeconds: 0),
    _ExerciseStep(name: 'Child Pose', sets: 1, reps: 30, restSeconds: 0),
  ];

  int _currentExerciseIndex = 1; // mulai di Push-Up (after Jumping Jacks done)
  int _currentSet = 2;
  int _totalSeconds = 754; // ~12:34
  int _restRemaining = 0;
  bool _isResting = false;
  bool _isPaused = false;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      setState(() {
        _totalSeconds++;
        if (_isResting && _restRemaining > 0) {
          _restRemaining--;
          if (_restRemaining == 0) {
            _isResting = false;
          }
        }
      });
    });
  }

  _ExerciseStep get _currentStep => _steps[_currentExerciseIndex];

  void _onPrev() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSet = 1;
        _isResting = false;
      });
    }
  }

  void _onNext() {
    if (_currentSet < _currentStep.sets) {
      // Mulai rest dulu
      setState(() {
        _currentSet++;
        _isResting = true;
        _restRemaining = _currentStep.restSeconds;
      });
    } else if (_currentExerciseIndex < _steps.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _isResting = false;
      });
    } else {
      // Semua selesai
      _onFinish();
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _onFinish() {
    _ticker?.cancel();
    context.go('/workout/complete/${widget.workoutId}');
  }

  Future<void> _confirmEarlyFinish() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesai Lebih Awal?'),
        content: const Text(
          'Latihan kamu akan dicatat sesuai progress saat ini. '
          'Mau lanjut atau berhenti?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjutkan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.warning),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentExerciseIndex + 1) / _steps.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ───
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.sm,
                AppDimensions.sm,
                AppDimensions.sm,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    color: AppColors.textPrimary,
                    onPressed: _confirmEarlyFinish,
                    tooltip: 'Selesai lebih awal',
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LATIHAN BERLANGSUNG',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Latihan ${_currentExerciseIndex + 1} dari ${_steps.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _confirmEarlyFinish,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                    ),
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.sm),

            // ─── Total Timer ───
            WorkoutTimerDisplay(
              totalSeconds: _totalSeconds,
              label: 'TOTAL WAKTU',
              fontSize: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.lg),

            // ─── Exercise card / Rest card ───
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _isResting
                    ? _RestCard(
                        remainingSeconds: _restRemaining,
                        totalRestSeconds:
                            _currentStep.restSeconds.clamp(1, 999),
                        nextExerciseName: _currentStep.name,
                        currentSet: _currentSet,
                        totalSets: _currentStep.sets,
                      )
                    : _ExerciseCard(
                        step: _currentStep,
                        currentSet: _currentSet,
                      ),
              ),
            ),

            // ─── Kontrol Row ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
                vertical: AppDimensions.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: Icons.skip_previous,
                    onTap:
                        _currentExerciseIndex > 0 ? _onPrev : null,
                    size: 56,
                  ),
                  _ControlButton(
                    icon: _isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    onTap: _togglePause,
                    size: 72,
                    isPrimary: true,
                  ),
                  _ControlButton(
                    icon: Icons.skip_next,
                    onTap: _onNext,
                    size: 56,
                  ),
                ],
              ),
            ),

            // ─── Bottom progress ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
                vertical: AppDimensions.md,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXERCISE CARD (saat sedang latihan)
// ═══════════════════════════════════════════════════════════════

class _ExerciseCard extends StatelessWidget {
  final _ExerciseStep step;
  final int currentSet;

  const _ExerciseCard({
    required this.step,
    required this.currentSet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LATIHAN AKTIF',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              step.name,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Sets indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(step.sets, (i) {
              final isDone = i < currentSet - 1;
              final isCurrent = i == currentSet - 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: isCurrent ? 36 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.accent
                            : AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppDimensions.md),

          Text(
            'Set $currentSet dari ${step.sets}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Big reps counter
          Text(
            'REPETISI',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${step.reps}',
              style: AppTextStyles.display.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: 96,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.base,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Selesaikan set, lalu istirahat',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REST CARD (saat sedang istirahat)
// ═══════════════════════════════════════════════════════════════

class _RestCard extends StatelessWidget {
  final int remainingSeconds;
  final int totalRestSeconds;
  final String nextExerciseName;
  final int currentSet;
  final int totalSets;

  const _RestCard({
    required this.remainingSeconds,
    required this.totalRestSeconds,
    required this.nextExerciseName,
    required this.currentSet,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalRestSeconds <= 0
        ? 1.0
        : (1 - remainingSeconds / totalRestSeconds).clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ISTIRAHAT',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor:
                      AppColors.accent.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.accent,
                  ),
                ),
              ),
              WorkoutTimerDisplay(
                totalSeconds: remainingSeconds,
                fontSize: 56,
                color: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            'Lanjut: $nextExerciseName',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Set $currentSet dari $totalSets',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CONTROL BUTTON
// ═══════════════════════════════════════════════════════════════

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 56,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final bg = isPrimary
        ? AppColors.accent
        : (isDisabled ? AppColors.surfaceLight : AppColors.surface);
    final fg = isPrimary
        ? AppColors.white
        : (isDisabled ? AppColors.textTertiary : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: isPrimary
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color:
                        AppColors.accent.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: size * 0.5, color: fg),
      ),
    );
  }
}
