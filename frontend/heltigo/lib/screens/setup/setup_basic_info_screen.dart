/// S-06: Setup Profile Step 1/7 — Data Dasar
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-06
///
/// Input:
/// - Nama Panggilan
/// - Tanggal Lahir (DatePicker)
/// - Usia (auto-calculated dari DOB vs DateTime.now())
/// - Jenis Kelamin (Laki-laki / Perempuan)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/selection_card.dart';
import '../../widgets/setup/setup_scaffold.dart';
import '../../providers/profile_draft_provider.dart';

enum _Gender { male, female }

class SetupBasicInfoScreen extends StatefulWidget {
  const SetupBasicInfoScreen({super.key});

  @override
  State<SetupBasicInfoScreen> createState() => _SetupBasicInfoScreenState();
}

class _SetupBasicInfoScreenState extends State<SetupBasicInfoScreen> {
  final _nameController = TextEditingController();
  DateTime? _dob;
  _Gender? _gender;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Hitung usia (dalam tahun) dari tanggal lahir vs hari ini.
  /// Adjust jika belum lewat ulang tahun tahun ini.
  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    final hasHadBirthdayThisYear = now.month > dob.month ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) age--;
    return age;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    // Min usia 10 tahun, max usia 100 tahun
    final firstDate = DateTime(now.year - 100, now.month, now.day);
    final lastDate = DateTime(now.year - 10, now.month, now.day);
    final initial = _dob ?? DateTime(now.year - 22, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFF5F5F5),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _dob = picked);
    }
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      _dob != null &&
      _gender != null;

  void _onContinue() {
    final draft = context.read<ProfileDraftProvider>();
    draft.updateBasicInfo(
      name: _nameController.text.trim(),
      age: _dob != null ? _calculateAge(_dob!) : null,
      gender: _gender == _Gender.male ? 'M' : 'F',
    );
    context.push('/setup-physical');
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      currentStep: 1,
      title: 'Hai! Kenalkan dirimu',
      subtitle: 'Kami perlu informasi dasar untuk mulai membuat rencanamu.',
      onContinue: _canContinue ? _onContinue : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // NAMA PANGGILAN
          // ═══════════════════════════════════════
          _fieldLabel('Nama Panggilanmu'),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'mis. Andra',
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // TANGGAL LAHIR (DatePicker trigger)
          // ═══════════════════════════════════════
          _fieldLabel('Tanggal Lahir'),
          const SizedBox(height: AppDimensions.sm),
          _DobPickerTile(
            dob: _dob,
            onTap: _pickDateOfBirth,
          ),

          // ═══════════════════════════════════════
          // USIA OTOMATIS (muncul setelah DOB dipilih)
          // ═══════════════════════════════════════
          if (_dob != null) ...[
            const SizedBox(height: AppDimensions.md),
            _AutoAgeCard(age: _calculateAge(_dob!)),
          ],

          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // JENIS KELAMIN
          // ═══════════════════════════════════════
          _fieldLabel('Jenis Kelamin'),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Expanded(
                child: SelectionCard(
                  label: 'Laki-laki',
                  icon: Icons.male,
                  isSelected: _gender == _Gender.male,
                  onTap: () => setState(() => _gender = _Gender.male),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: SelectionCard(
                  label: 'Perempuan',
                  icon: Icons.female,
                  isSelected: _gender == _Gender.female,
                  onTap: () => setState(() => _gender = _Gender.female),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: label di atas field
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
// DOB PICKER TILE — Container yang trigger DatePicker
// ═══════════════════════════════════════════════════════════════

class _DobPickerTile extends StatelessWidget {
  final DateTime? dob;
  final VoidCallback onTap;

  const _DobPickerTile({required this.dob, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = dob != null;
    final displayText = hasValue
        ? DateFormat('dd MMMM yyyy', 'id').format(dob!)
        : 'Pilih tanggal lahir';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: Container(
        height: AppDimensions.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.base),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                displayText,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AUTO AGE CARD — display usia hasil kalkulasi
// ═══════════════════════════════════════════════════════════════

class _AutoAgeCard extends StatelessWidget {
  final int age;

  const _AutoAgeCard({required this.age});

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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_outlined,
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
                  const TextSpan(text: 'Usiamu: '),
                  TextSpan(
                    text: '$age tahun',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
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
