/// S-33: App Settings Screen — pengaturan tampilan, data, dan tentang
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-33
///
/// Sections:
/// - TAMPILAN: Mode Gelap, Satuan, Bahasa
/// - DATA: Ekspor CSV, Reset Semua Data
/// - TENTANG: Heltigo version
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

enum _Unit { metric, imperial }

enum _Language { id, en }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Dark mode locked ON karena app dark-only
  final bool _darkMode = true;
  _Unit _unit = _Unit.metric;
  _Language _language = _Language.id;

  String _unitLabel(_Unit u) =>
      u == _Unit.metric ? 'Metrik (kg, cm)' : 'Imperial (lbs, inch)';

  String _languageLabel(_Language l) =>
      l == _Language.id ? 'Bahasa Indonesia' : 'English';

  void _showTodoSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickUnit() async {
    final result = await showModalBottomSheet<_Unit>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusBottomSheetTop),
        ),
      ),
      builder: (ctx) => _PickerSheet<_Unit>(
        title: 'Pilih Satuan',
        current: _unit,
        options: const [
          (value: _Unit.metric, label: 'Metrik (kg, cm)'),
          (value: _Unit.imperial, label: 'Imperial (lbs, inch)'),
        ],
      ),
    );
    if (result != null) setState(() => _unit = result);
  }

  Future<void> _pickLanguage() async {
    final result = await showModalBottomSheet<_Language>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusBottomSheetTop),
        ),
      ),
      builder: (ctx) => _PickerSheet<_Language>(
        title: 'Pilih Bahasa',
        current: _language,
        options: const [
          (value: _Language.id, label: 'Bahasa Indonesia'),
          (value: _Language.en, label: 'English'),
        ],
      ),
    );
    if (result != null) setState(() => _language = result);
  }

  void _confirmReset() {
    final controller = TextEditingController();
    bool canConfirm = false;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              title: const Text('Reset Semua Data?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aksi ini akan menghapus seluruh data profil, rencana, '
                    'dan log. Tidak bisa dibatalkan.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Ketik "RESET" untuk konfirmasi:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.error,
                    onChanged: (v) {
                      setStateDialog(() => canConfirm = v == 'RESET');
                    },
                    decoration: const InputDecoration(
                      hintText: 'RESET',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: canConfirm
                      ? () {
                          Navigator.of(dialogCtx).pop();
                          _showTodoSnack('Reset data akan dilakukan');
                        }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            );
          },
        );
      },
    );
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
        title: Text('Pengaturan App', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.base,
            vertical: AppDimensions.sm,
          ),
          children: [
            // ═══════════════════════════════════════
            // TAMPILAN
            // ═══════════════════════════════════════
            _SectionLabel('TAMPILAN'),
            const SizedBox(height: AppDimensions.sm),
            _SettingsGroup(
              children: [
                _SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Mode Gelap',
                  subtitle: 'Saat ini hanya tersedia dark mode',
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: null, // Locked ON
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                _SettingsItem(
                  icon: Icons.straighten,
                  title: 'Satuan',
                  trailing: _ValueChevron(label: _unitLabel(_unit)),
                  onTap: _pickUnit,
                ),
                _SettingsItem(
                  icon: Icons.language_outlined,
                  title: 'Bahasa',
                  trailing: _ValueChevron(label: _languageLabel(_language)),
                  onTap: _pickLanguage,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),

            // ═══════════════════════════════════════
            // DATA
            // ═══════════════════════════════════════
            _SectionLabel('DATA'),
            const SizedBox(height: AppDimensions.sm),
            _SettingsGroup(
              children: [
                _SettingsItem(
                  icon: Icons.file_download_outlined,
                  title: 'Ekspor Data CSV',
                  subtitle: 'Unduh log latihan, makan, & berat',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onTap: () => _showTodoSnack(
                    'Fitur ekspor sedang dibuat',
                  ),
                ),
                _SettingsItem(
                  icon: Icons.delete_outline,
                  title: 'Reset Semua Data',
                  subtitle: 'Hapus seluruh data lokal',
                  isDanger: true,
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onTap: _confirmReset,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),

            // ═══════════════════════════════════════
            // TENTANG
            // ═══════════════════════════════════════
            _SectionLabel('TENTANG'),
            const SizedBox(height: AppDimensions.sm),
            _SettingsGroup(
              children: [
                _SettingsItem(
                  icon: Icons.info_outline,
                  title: 'Heltigo v1.0.0',
                  subtitle: 'Aplikasi Kesehatan & Kebugaran Personal',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onTap: () => context.push('/about'),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),

            Center(
              child: Text(
                'Heltigo · Made with Flutter',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.overline.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS GROUP — container surface yang grouping items dengan divider
// ═══════════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS ITEM — row dengan icon, title, subtitle, trailing
// ═══════════════════════════════════════════════════════════════

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isLast;
  final bool isDanger;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
    this.isLast = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDanger ? AppColors.error : AppColors.primary;
    final titleColor = isDanger ? AppColors.error : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.base,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusInput),
              ),
              child: Icon(icon, size: 18, color: accentColor),
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
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VALUE CHEVRON — text "value" + chevron right
// ═══════════════════════════════════════════════════════════════

class _ValueChevron extends StatelessWidget {
  final String label;

  const _ValueChevron({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
          size: 20,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PICKER SHEET — generic bottom sheet untuk pilih dari options
// ═══════════════════════════════════════════════════════════════

class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final T current;
  final List<({T value, String label})> options;

  const _PickerSheet({
    required this.title,
    required this.current,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.md),
            ...options.map((opt) {
              final isSelected = opt.value == current;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(opt.value),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryMuted
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusInput,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt.label,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
