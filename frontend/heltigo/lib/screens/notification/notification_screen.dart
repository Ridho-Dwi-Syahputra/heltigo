/// S-32: Notification Settings Screen — konfigurasi pengingat
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-32
///
/// Sections:
/// - Master switch "Aktifkan Semua Notifikasi"
/// - Latihan (with time picker + warmup sub-toggle)
/// - Makan (Sarapan/Siang/Malam dengan time picker masing-masing)
/// - Hidrasi (frekuensi dropdown)
/// - Laporan Mingguan (with time picker)
/// - Sticky tombol "Simpan Pengaturan"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Master
  bool _masterEnabled = true;

  // Latihan
  bool _workoutEnabled = true;
  bool _warmupEnabled = true;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 6, minute: 0);

  // Makan
  bool _breakfastEnabled = true;
  bool _lunchEnabled = true;
  bool _dinnerEnabled = true;
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);

  // Hidrasi
  bool _hydrationEnabled = true;
  int _hydrationFrequency = 2; // 1, 2, atau 3 jam

  // Laporan
  bool _weeklyReportEnabled = true;
  TimeOfDay _weeklyReportTime = const TimeOfDay(hour: 20, minute: 0);

  Future<void> _pickTime(TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFF5F5F5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _onSave() {
    // TODO: ProfileProvider.updateNotificationPrefs(...)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan notifikasi tersimpan'),
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
      appBar: AppBar(
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
        title: Text('Notifikasi', style: AppTextStyles.h3),
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
                    // MASTER SWITCH
                    // ═══════════════════════════════════════
                    _MasterCard(
                      enabled: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _masterEnabled = v),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // ═══════════════════════════════════════
                    // LATIHAN
                    // ═══════════════════════════════════════
                    _SectionLabel('LATIHAN'),
                    const SizedBox(height: AppDimensions.sm),
                    _NotifTile(
                      icon: Icons.fitness_center,
                      title: 'Pengingat Latihan',
                      subtitle: 'Notifikasi sebelum jadwal latihan',
                      enabled: _masterEnabled && _workoutEnabled,
                      isInteractive: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _workoutEnabled = v),
                      trailing: _TimeChip(
                        time: _formatTime(_workoutTime),
                        enabled: _masterEnabled && _workoutEnabled,
                        onTap: () => _pickTime(
                          _workoutTime,
                          (t) => setState(() => _workoutTime = t),
                        ),
                      ),
                    ),
                    _NotifTile(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Pemanasan 15 Menit',
                      subtitle: 'Notifikasi 15 menit sebelum sesi',
                      enabled:
                          _masterEnabled && _workoutEnabled && _warmupEnabled,
                      isInteractive: _masterEnabled && _workoutEnabled,
                      onChanged: (v) =>
                          setState(() => _warmupEnabled = v),
                      indented: true,
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // ═══════════════════════════════════════
                    // MAKAN
                    // ═══════════════════════════════════════
                    _SectionLabel('MAKAN'),
                    const SizedBox(height: AppDimensions.sm),
                    _NotifTile(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Sarapan',
                      subtitle: 'Pengingat 10 menit sebelum',
                      enabled: _masterEnabled && _breakfastEnabled,
                      isInteractive: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _breakfastEnabled = v),
                      trailing: _TimeChip(
                        time: _formatTime(_breakfastTime),
                        enabled: _masterEnabled && _breakfastEnabled,
                        onTap: () => _pickTime(
                          _breakfastTime,
                          (t) => setState(() => _breakfastTime = t),
                        ),
                      ),
                    ),
                    _NotifTile(
                      icon: Icons.restaurant_outlined,
                      title: 'Makan Siang',
                      subtitle: 'Pengingat 10 menit sebelum',
                      enabled: _masterEnabled && _lunchEnabled,
                      isInteractive: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _lunchEnabled = v),
                      trailing: _TimeChip(
                        time: _formatTime(_lunchTime),
                        enabled: _masterEnabled && _lunchEnabled,
                        onTap: () => _pickTime(
                          _lunchTime,
                          (t) => setState(() => _lunchTime = t),
                        ),
                      ),
                    ),
                    _NotifTile(
                      icon: Icons.dinner_dining_outlined,
                      title: 'Makan Malam',
                      subtitle: 'Pengingat 10 menit sebelum',
                      enabled: _masterEnabled && _dinnerEnabled,
                      isInteractive: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _dinnerEnabled = v),
                      trailing: _TimeChip(
                        time: _formatTime(_dinnerTime),
                        enabled: _masterEnabled && _dinnerEnabled,
                        onTap: () => _pickTime(
                          _dinnerTime,
                          (t) => setState(() => _dinnerTime = t),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // ═══════════════════════════════════════
                    // HIDRASI
                    // ═══════════════════════════════════════
                    _SectionLabel('HIDRASI'),
                    const SizedBox(height: AppDimensions.sm),
                    _NotifTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Pengingat Hidrasi',
                      subtitle: 'Setiap $_hydrationFrequency jam',
                      enabled: _masterEnabled && _hydrationEnabled,
                      isInteractive: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _hydrationEnabled = v),
                      trailing: _FrequencyDropdown(
                        value: _hydrationFrequency,
                        enabled:
                            _masterEnabled && _hydrationEnabled,
                        onChanged: (v) => setState(
                            () => _hydrationFrequency = v),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // ═══════════════════════════════════════
                    // LAPORAN MINGGUAN
                    // ═══════════════════════════════════════
                    _SectionLabel('LAPORAN'),
                    const SizedBox(height: AppDimensions.sm),
                    _NotifTile(
                      icon: Icons.assessment_outlined,
                      title: 'Laporan Mingguan',
                      subtitle: 'Evaluasi mingguan · Minggu malam',
                      enabled: _masterEnabled && _weeklyReportEnabled,
                      isInteractive: _masterEnabled,
                      onChanged: (v) =>
                          setState(() => _weeklyReportEnabled = v),
                      trailing: _TimeChip(
                        time: _formatTime(_weeklyReportTime),
                        enabled:
                            _masterEnabled && _weeklyReportEnabled,
                        onTap: () => _pickTime(
                          _weeklyReportTime,
                          (t) => setState(
                              () => _weeklyReportTime = t),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // STICKY SAVE BUTTON
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base,
              ),
              child: PrimaryButton(
                label: 'Simpan Pengaturan',
                onPressed: _onSave,
                icon: Icons.check,
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
      style: AppTextStyles.overline.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MASTER CARD — switch besar
// ═══════════════════════════════════════════════════════════════

class _MasterCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _MasterCard({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.base,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: enabled ? AppColors.primaryMuted : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: enabled ? AppColors.primary : AppColors.border,
          width: enabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Aktifkan Semua Notifikasi',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Master switch · matikan untuk hentikan semua',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIF TILE — row dengan icon, title, sub, trailing widget, switch
// ═══════════════════════════════════════════════════════════════

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool isInteractive;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;
  final bool indented;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.isInteractive,
    required this.onChanged,
    this.trailing,
    this.indented = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isInteractive ? 1.0 : 0.5,
      child: Padding(
        padding: EdgeInsets.only(
          left: indented ? AppDimensions.lg : 0,
          bottom: AppDimensions.sm,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.base,
            vertical: AppDimensions.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: AppDimensions.sm),
              ],
              Switch(
                value: enabled,
                onChanged: isInteractive ? onChanged : null,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TIME CHIP — tap to open time picker
// ═══════════════════════════════════════════════════════════════

class _TimeChip extends StatelessWidget {
  final String time;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm + 4,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: enabled
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FREQUENCY DROPDOWN — pilih 1/2/3 jam
// ═══════════════════════════════════════════════════════════════

class _FrequencyDropdown extends StatelessWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _FrequencyDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          dropdownColor: AppColors.surfaceElevated,
          style: AppTextStyles.caption.copyWith(
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontWeight: FontWeight.w700,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: enabled
                ? AppColors.textSecondary
                : AppColors.textTertiary,
            size: 18,
          ),
          isDense: true,
          onChanged: enabled
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 jam')),
            DropdownMenuItem(value: 2, child: Text('2 jam')),
            DropdownMenuItem(value: 3, child: Text('3 jam')),
          ],
        ),
      ),
    );
  }
}
