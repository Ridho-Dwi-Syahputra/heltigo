/// S-11: Setup Profile Step 6/7 — Preferensi Latihan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-11
///
/// Input:
/// - Mode: Home Workout / Gym
/// - Hari per Minggu: 3 / 4 / 5
/// - Durasi Sesi: 15 / 30 / 45 / 60 menit
/// - Waktu Favorit: Pagi / Siang / Sore / Malam (multi-select)
/// - Level: Pemula / Menengah / Mahir
///
/// File name kept as setup_fitness_level_screen.dart untuk kompatibilitas router.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/chip_multi_select.dart';
import '../../widgets/setup/segmented_selector.dart';
import '../../widgets/setup/selection_card.dart';
import '../../widgets/setup/setup_scaffold.dart';

enum _WorkoutMode { home, gym }

class SetupFitnessLevelScreen extends StatefulWidget {
  const SetupFitnessLevelScreen({super.key});

  @override
  State<SetupFitnessLevelScreen> createState() =>
      _SetupFitnessLevelScreenState();
}

class _SetupFitnessLevelScreenState extends State<SetupFitnessLevelScreen> {
  _WorkoutMode? _mode;
  int _daysIndex = 1; // 0=3 hari, 1=4 hari, 2=5 hari
  int _durationIndex = 1; // 0=15, 1=30, 2=45, 3=60
  Set<int> _favoriteTimes = {0}; // Default: pagi
  int _levelIndex = 0; // 0=pemula, 1=menengah, 2=mahir

  static const List<String> _daysOptions = ['3 Hari', '4 Hari', '5 Hari'];
  static const List<String> _durationOptions = [
    '15 mnt',
    '30 mnt',
    '45 mnt',
    '60 mnt'
  ];
  static const List<ChipOption> _timeOptions = [
    ChipOption(label: 'Pagi', icon: Icons.wb_twilight),
    ChipOption(label: 'Siang', icon: Icons.wb_sunny_outlined),
    ChipOption(label: 'Sore', icon: Icons.wb_cloudy_outlined),
    ChipOption(label: 'Malam', icon: Icons.nights_stay_outlined),
  ];
  static const List<String> _levelOptions = ['Pemula', 'Menengah', 'Mahir'];
  static const List<String> _levelDescriptions = [
    'Baru mulai latihan rutin',
    'Sudah latihan 3–6 bulan',
    'Latihan rutin 1+ tahun',
  ];

  bool get _canContinue => _mode != null && _favoriteTimes.isNotEmpty;

  void _onContinue() {
    // TODO: Save workout preferences ke ProfileProvider
    context.push('/setup-preferences');
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      currentStep: 6,
      title: 'Atur preferensi latihanmu',
      subtitle: 'Beritahu kami bagaimana kamu suka berlatih.',
      onContinue: _canContinue ? _onContinue : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // MODE
          // ═══════════════════════════════════════
          _sectionLabel('Mode Latihan'),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Expanded(
                child: SelectionCard(
                  label: 'Home Workout',
                  subtitle: 'Tanpa Alat',
                  icon: Icons.home_outlined,
                  isSelected: _mode == _WorkoutMode.home,
                  onTap: () => setState(() => _mode = _WorkoutMode.home),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: SelectionCard(
                  label: 'Gym',
                  subtitle: 'Dengan Alat',
                  icon: Icons.fitness_center,
                  isSelected: _mode == _WorkoutMode.gym,
                  onTap: () => setState(() => _mode = _WorkoutMode.gym),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // HARI PER MINGGU
          // ═══════════════════════════════════════
          _sectionLabel('Hari per Minggu'),
          const SizedBox(height: AppDimensions.sm),
          SegmentedSelector(
            options: _daysOptions,
            selectedIndex: _daysIndex,
            onChanged: (i) => setState(() => _daysIndex = i),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // DURASI SESI
          // ═══════════════════════════════════════
          _sectionLabel('Durasi Sesi'),
          const SizedBox(height: AppDimensions.sm),
          SegmentedSelector(
            options: _durationOptions,
            selectedIndex: _durationIndex,
            onChanged: (i) => setState(() => _durationIndex = i),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // WAKTU FAVORIT
          // ═══════════════════════════════════════
          _sectionLabel('Waktu Favorit'),
          const SizedBox(height: AppDimensions.sm),
          ChipMultiSelect(
            options: _timeOptions,
            selectedIndices: _favoriteTimes,
            onChanged: (next) => setState(() => _favoriteTimes = next),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // LEVEL
          // ═══════════════════════════════════════
          _sectionLabel('Level Kebugaran'),
          const SizedBox(height: AppDimensions.sm),
          SegmentedSelector(
            options: _levelOptions,
            selectedIndex: _levelIndex,
            onChanged: (i) => setState(() => _levelIndex = i),
          ),
          const SizedBox(height: AppDimensions.sm),
          // Deskripsi dinamis di bawah level
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: Text(
                    _levelDescriptions[_levelIndex],
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
