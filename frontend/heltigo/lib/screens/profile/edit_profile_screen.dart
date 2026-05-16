/// S-31: Edit Profile Screen — edit data profil user
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-31
///
/// Sections:
/// - DATA DASAR: Nama, Usia, Jenis Kelamin
/// - DATA FISIK: Tinggi, Berat Terkini, Lingkar Pinggang + BMI live card
/// - TUJUAN: Goal selector (bottom sheet) + warning info
/// - Sticky button "Simpan Perubahan"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/selection_card.dart';
import '../../widgets/universal/primary_button.dart';

enum _Gender { male, female }

enum _Goal { lose, maintain, gain }

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Form controllers — initial mock data
  final _nameController = TextEditingController(text: 'Andra Pratama');
  final _ageController = TextEditingController(text: '24');
  final _heightController = TextEditingController(text: '172');
  final _weightController = TextEditingController(text: '74.2');
  final _waistController = TextEditingController(text: '84');

  _Gender _gender = _Gender.male;
  _Goal _goal = _Goal.lose;
  final String _targetWeight = '68';

  // BMI live values
  double _liveBmi = 25.1;
  String _liveCategory = 'Sedikit Lebih';

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_recalculateBmi);
    _weightController.addListener(_recalculateBmi);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  void _recalculateBmi() {
    final h = double.tryParse(_heightController.text) ?? 0;
    final w = double.tryParse(_weightController.text) ?? 0;
    if (h <= 0 || w <= 0) return;
    final heightM = h / 100;
    final bmi = w / (heightM * heightM);
    setState(() {
      _liveBmi = bmi;
      _liveCategory = _bmiCategoryFromValue(bmi);
    });
  }

  String _bmiCategoryFromValue(double bmi) {
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sedikit Lebih';
    return 'Obesitas';
  }

  Color _bmiCategoryColor(double bmi) {
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  String _goalLabel(_Goal g) {
    switch (g) {
      case _Goal.lose:
        return 'Turunkan Berat';
      case _Goal.maintain:
        return 'Jaga Berat';
      case _Goal.gain:
        return 'Naikkan Massa Otot';
    }
  }

  IconData _goalIcon(_Goal g) {
    switch (g) {
      case _Goal.lose:
        return Icons.trending_down;
      case _Goal.maintain:
        return Icons.trending_flat;
      case _Goal.gain:
        return Icons.trending_up;
    }
  }

  Future<void> _pickGoal() async {
    final result = await showModalBottomSheet<_Goal>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusBottomSheetTop),
        ),
      ),
      builder: (ctx) => _GoalPickerSheet(current: _goal),
    );
    if (result != null) {
      setState(() => _goal = result);
    }
  }

  void _onSave() {
    final hasGoalChanged = _goal != _Goal.lose; // mock comparison
    if (hasGoalChanged) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Konfirmasi Perubahan'),
          content: const Text(
            'Mengubah tujuan akan membuat AI merancang ulang rencana minggu ini. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _saveAndPop();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } else {
      _saveAndPop();
    }
  }

  void _saveAndPop() {
    // TODO: ProfileProvider.update(...)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan profil tersimpan'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text('Edit Profil', style: AppTextStyles.h3),
        actions: [
          TextButton(
            onPressed: _onSave,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              'Simpan',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ═══════════════════════════════════════
                    // DATA DASAR
                    // ═══════════════════════════════════════
                    _SectionHeader(label: 'DATA DASAR'),
                    const SizedBox(height: AppDimensions.sm),
                    _fieldLabel('Nama'),
                    const SizedBox(height: AppDimensions.xs + 2),
                    TextFormField(
                      controller: _nameController,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    _fieldLabel('Usia'),
                    const SizedBox(height: AppDimensions.xs + 2),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        suffixText: 'tahun',
                        suffixStyle: TextStyle(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    _fieldLabel('Jenis Kelamin'),
                    const SizedBox(height: AppDimensions.xs + 2),
                    Row(
                      children: [
                        Expanded(
                          child: SelectionCard(
                            label: 'Laki-laki',
                            icon: Icons.male,
                            isSelected: _gender == _Gender.male,
                            onTap: () =>
                                setState(() => _gender = _Gender.male),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: SelectionCard(
                            label: 'Perempuan',
                            icon: Icons.female,
                            isSelected: _gender == _Gender.female,
                            onTap: () =>
                                setState(() => _gender = _Gender.female),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // ═══════════════════════════════════════
                    // DATA FISIK
                    // ═══════════════════════════════════════
                    _SectionHeader(label: 'DATA FISIK'),
                    const SizedBox(height: AppDimensions.sm),
                    _fieldLabel('Tinggi'),
                    const SizedBox(height: AppDimensions.xs + 2),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.height,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        suffixText: 'cm',
                        suffixStyle:
                            TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    _fieldLabel('Berat Terkini'),
                    const SizedBox(height: AppDimensions.xs + 2),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.monitor_weight_outlined,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        suffixText: 'kg',
                        suffixStyle:
                            TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    _fieldLabel('Lingkar Pinggang (opsional)'),
                    const SizedBox(height: AppDimensions.xs + 2),
                    TextFormField(
                      controller: _waistController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.straighten,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                        suffixText: 'cm',
                        suffixStyle:
                            TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // BMI Live Card
                    _BmiLiveCard(
                      bmi: _liveBmi,
                      category: _liveCategory,
                      categoryColor: _bmiCategoryColor(_liveBmi),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // ═══════════════════════════════════════
                    // TUJUAN
                    // ═══════════════════════════════════════
                    _SectionHeader(label: 'TUJUAN'),
                    const SizedBox(height: AppDimensions.sm),

                    InkWell(
                      onTap: _pickGoal,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusInput),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.base,
                          vertical: AppDimensions.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusInput,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _goalIcon(_goal),
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _goalLabel(_goal),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_goal != _Goal.maintain) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Target: $_targetWeight kg',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Warning info
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: AppColors.warningMuted,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusInput,
                        ),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_outlined,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: Text(
                              'Mengubah tujuan akan membuat AI merancang '
                              'ulang rencana minggu ini.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // STICKY BOTTOM BUTTON
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base,
              ),
              child: PrimaryButton(
                label: 'Simpan Perubahan',
                onPressed: _onSave,
                icon: Icons.check,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.overline.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BMI LIVE CARD
// ═══════════════════════════════════════════════════════════════

class _BmiLiveCard extends StatelessWidget {
  final double bmi;
  final String category;
  final Color categoryColor;

  const _BmiLiveCard({
    required this.bmi,
    required this.category,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.base,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.analytics_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'BMI: '),
                  TextSpan(
                    text: bmi.toStringAsFixed(1),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' — '),
                  TextSpan(
                    text: category,
                    style: AppTextStyles.body.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GOAL PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _GoalPickerSheet extends StatelessWidget {
  final _Goal current;

  const _GoalPickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final options = <({_Goal goal, String label, IconData icon, String desc})>[
      (
        goal: _Goal.lose,
        label: 'Turunkan Berat',
        icon: Icons.trending_down,
        desc: 'Bakar lemak, capai berat ideal',
      ),
      (
        goal: _Goal.maintain,
        label: 'Jaga Berat',
        icon: Icons.trending_flat,
        desc: 'Pertahankan kondisi saat ini',
      ),
      (
        goal: _Goal.gain,
        label: 'Naikkan Massa Otot',
        icon: Icons.trending_up,
        desc: 'Bulking, tingkatkan kekuatan',
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.base),
            Text('Pilih Tujuan', style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.md),
            ...options.map((opt) {
              final isSelected = opt.goal == current;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(opt.goal),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryMuted
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusInput),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          opt.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                opt.label,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(opt.desc, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
