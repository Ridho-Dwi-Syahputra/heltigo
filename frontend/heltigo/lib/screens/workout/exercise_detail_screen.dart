/// S-18: Exercise Detail Screen — detail satu gerakan latihan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-18
///
/// Sections:
/// 1. AppBar dengan nama exercise + back
/// 2. Tag chips (equipment, muscle, difficulty)
/// 3. Image placeholder besar
/// 4. Info card: Set × Reps + istirahat
/// 5. Cara Melakukan (numbered list)
/// 6. Target Otot chips
/// 7. Tips AI card
/// 8. SecondaryButton "Ganti Latihan Ini"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/secondary_button.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  // ─── Mock data (provider integration nanti) ───
  String get _name {
    if (exerciseId.contains('plank')) return 'Plank';
    if (exerciseId.contains('squat')) return 'Squat';
    if (exerciseId.contains('jumping-jacks')) return 'Jumping Jacks';
    return 'Push-Up';
  }

  String get _description {
    if (exerciseId.contains('plank')) {
      return 'Latihan core isometrik untuk memperkuat otot perut, '
          'punggung bawah, dan stabilitas tubuh.';
    }
    return 'Latihan klasik bodyweight untuk dada, bahu, trisep, dan core. '
        'Fokus pada kontrol gerakan dan posisi tubuh lurus.';
  }

  int get _sets => 4;
  int get _reps => 12;
  int get _restSeconds => 60;

  List<String> get _instructions {
    if (exerciseId.contains('plank')) {
      return const [
        'Posisi awal: telungkup dengan siku di bawah bahu.',
        'Angkat tubuh dengan menumpu pada lengan bawah dan ujung kaki.',
        'Pertahankan tubuh lurus dari kepala hingga tumit.',
        'Kencangkan otot perut dan jaga napas tetap normal.',
        'Tahan posisi sesuai target waktu (mis. 30-60 detik).',
      ];
    }
    return const [
      'Posisi awal dengan tangan selebar bahu, badan lurus.',
      'Turunkan tubuh perlahan hingga dada hampir menyentuh lantai.',
      'Tahan 1 detik, lalu dorong kembali ke posisi awal.',
      'Jaga punggung tetap lurus dan inti kencang.',
      'Bernapas teratur — turun dengan tarik napas, naik buang.',
    ];
  }

  List<({String label, Color color})> get _tags => const [
        (label: 'Bodyweight', color: AppColors.primary),
        (label: 'Dada', color: AppColors.accent),
        (label: 'Pemula', color: AppColors.info),
      ];

  List<String> get _targetMuscles => const [
        'Dada (Pectoralis)',
        'Bahu (Deltoid)',
        'Trisep',
        'Core',
      ];

  String get _aiTip {
    return 'Karena BMI kamu masuk kategori "Sedikit Lebih", '
        'mulai dengan 8 reps × 3 set lalu naikkan bertahap. '
        'Pertahankan tempo lambat untuk membentuk teknik yang benar.';
  }

  void _showSwapSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih latihan pengganti — coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
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
        title: Text(_name, style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simpan latihan ke favorit'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Simpan',
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.only(
            left: AppDimensions.base,
            right: AppDimensions.base,
            top: AppDimensions.sm,
            bottom: AppDimensions.xxxl + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            // ─── 1. Tag chips ───
            Wrap(
              spacing: AppDimensions.xs + 2,
              runSpacing: AppDimensions.xs + 2,
              children: _tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm + 2,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tag.color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border:
                        Border.all(color: tag.color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    tag.label,
                    style: AppTextStyles.caption.copyWith(
                      color: tag.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.md),

            // ─── 2. Image placeholder ───
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    Positioned(
                      bottom: AppDimensions.sm,
                      left: AppDimensions.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm + 2,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_outline,
                              size: 12,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tutorial Video',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ─── 3. Big info card: Set × Reps ───
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_sets',
                        style: AppTextStyles.numberBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs + 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Set',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.base),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '×',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.base),
                      Text(
                        '$_reps',
                        style: AppTextStyles.numberBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs + 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Reps',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Istirahat $_restSeconds detik antar set',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ─── 4. Description ───
            Text(
              _description,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppDimensions.lg),

            // ─── 5. Cara Melakukan ───
            Text(
              'CARA MELAKUKAN',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            ...List.generate(_instructions.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm + 2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _instructions[i],
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppDimensions.lg),

            // ─── 6. Target Otot ───
            Text(
              'TARGET OTOT',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: _targetMuscles.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm + 2,
                    vertical: AppDimensions.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.accessibility_new,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        m,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ─── 7. Tips AI card ───
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.warningMuted,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.warning,
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
                          'TIPS HELTIGO',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _aiTip,
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
            const SizedBox(height: AppDimensions.lg),

            // ─── 8. Swap button ───
            SecondaryButton(
              label: 'Ganti Latihan Ini',
              icon: Icons.swap_horiz,
              onPressed: () => _showSwapSnack(context),
            ),
          ],
        ),
      ),
    );
  }
}
