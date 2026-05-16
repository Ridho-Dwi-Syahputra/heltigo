/// S-30: Profile Screen — halaman profil pengguna
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-30
///
/// Sections:
/// 1. Hero header (avatar + nama + subtitle)
/// 2. Stats strip (Sesi/Latihan/Lencana/Minggu)
/// 3. Ringkasan kesehatan card (TB/BB/BMI/Target)
/// 4. Weight trend mini sparkline (visualisasi tambahan)
/// 5. Menu list (Edit/Notif/Budget/Tema/About/FAQ + Logout)
/// 6. Version footer
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/progress/weight_line_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ─── Mock data ───
  static const String _userName = 'Andra Pratama';
  static const String _userInitial = 'A';
  static const String _bmiCategory = 'Sedikit Lebih';
  static const String _joinedDate = 'Bergabung Mei 2026';

  static const _stats = [
    (label: 'Sesi', value: '12'),
    (label: 'Latihan', value: '42'),
    (label: 'Lencana', value: '8'),
    (label: 'Minggu', value: '3'),
  ];

  static const _summary = [
    (label: 'Tinggi', value: '172 cm', icon: Icons.height),
    (label: 'Berat', value: '74.2 kg', icon: Icons.monitor_weight_outlined),
    (label: 'BMI', value: '25.1', icon: Icons.analytics_outlined),
    (label: 'Target', value: '68 kg', icon: Icons.flag_outlined),
  ];

  // Mock weight trend (5 minggu)
  static const List<double> _weightTrend = [76.0, 75.5, 75.0, 74.5, 74.2];

  void _showTodoSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu akan diarahkan kembali ke halaman login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: AuthProvider.logout()
              GoRouter.of(context).go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('Profil', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: AppDimensions.xxxl + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          // ═══════════════════════════════════════
          // 1. HERO HEADER
          // ═══════════════════════════════════════
          _HeroSection(
            userName: _userName,
            userInitial: _userInitial,
            bmiCategory: _bmiCategory,
            joinedDate: _joinedDate,
          ),
          const SizedBox(height: AppDimensions.base),

          // ═══════════════════════════════════════
          // 2. STATS STRIP
          // ═══════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.base,
            ),
            child: _StatsStrip(stats: _stats),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // 3. RINGKASAN KESEHATAN
          // ═══════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.base,
            ),
            child: _SummaryCard(
              items: _summary,
              onEdit: () => context.push('/profile/edit'),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // 4. WEIGHT TREND MINI SPARKLINE
          // ═══════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.base,
            ),
            child: const _WeightTrendCard(values: _weightTrend),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // 5. MENU LIST
          // ═══════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.base,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MENU',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                _MenuTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profil',
                  subtitle: 'Ubah data dasar & fisik',
                  onTap: () => context.push('/profile/edit'),
                ),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  subtitle: 'Atur pengingat latihan & makan',
                  onTap: () => context.push('/notifications'),
                ),
                _MenuTile(
                  icon: Icons.attach_money_outlined,
                  label: 'Budget & Diet',
                  subtitle: 'Atur anggaran dan pantangan',
                  onTap: () => _showTodoSnack(
                    context,
                    'Halaman Budget & Diet sedang dibuat',
                  ),
                ),
                _MenuTile(
                  icon: Icons.palette_outlined,
                  label: 'Pengaturan App',
                  subtitle: 'Tema, satuan, bahasa, data',
                  onTap: () => context.push('/settings'),
                ),
                _MenuTile(
                  icon: Icons.info_outline,
                  label: 'Tentang Heltigo',
                  subtitle: 'Versi & informasi aplikasi',
                  onTap: () => context.push('/about'),
                ),
                _MenuTile(
                  icon: Icons.help_outline,
                  label: 'Bantuan & FAQ',
                  subtitle: 'Pertanyaan umum & dukungan',
                  onTap: () => _showTodoSnack(
                    context,
                    'Halaman Bantuan sedang dibuat',
                  ),
                ),
                const SizedBox(height: AppDimensions.base),
                _MenuTile(
                  icon: Icons.logout,
                  label: 'Keluar',
                  isDanger: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // ═══════════════════════════════════════
          // 6. VERSION FOOTER
          // ═══════════════════════════════════════
          Center(
            child: Text(
              'Heltigo v1.0.0 · Flutter',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO HEADER — gradient + avatar + nama
// ═══════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final String userName;
  final String userInitial;
  final String bmiCategory;
  final String joinedDate;

  const _HeroSection({
    required this.userName,
    required this.userInitial,
    required this.bmiCategory,
    required this.joinedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.base,
        AppDimensions.base,
        AppDimensions.base,
        AppDimensions.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusCard),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.4),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.white,
              child: Text(
                userInitial,
                style: AppTextStyles.display.copyWith(
                  fontSize: 32,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Nama
          Text(
            userName,
            style: AppTextStyles.h1.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppDimensions.xs),

          // Subtitle row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  bmiCategory,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                '·',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                joinedDate,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STATS STRIP — overlap hero, 4 cells
// ═══════════════════════════════════════════════════════════════

class _StatsStrip extends StatelessWidget {
  final List<({String label, String value})> stats;

  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Stats strip duduk normal di bawah hero (no overlap, beri gap rapi)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: List.generate(stats.length, (i) {
          return Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i > 0)
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.border,
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stats[i].value,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 22,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        stats[i].label,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SUMMARY CARD — 4 metric items + Edit button
// ═══════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final List<({String label, String value, IconData icon})> items;
  final VoidCallback onEdit;

  const _SummaryCard({required this.items, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Kesehatan', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.sm,
            crossAxisSpacing: AppDimensions.sm,
            childAspectRatio: 2.4,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm + 4,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.label,
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            item.value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit Profil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                minimumSize: const Size.fromHeight(42),
                textStyle: AppTextStyles.buttonSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WEIGHT TREND CARD — mini sparkline custom paint
// ═══════════════════════════════════════════════════════════════

class _WeightTrendCard extends StatelessWidget {
  final List<double> values;

  const _WeightTrendCard({required this.values});

  @override
  Widget build(BuildContext context) {
    final delta = values.isEmpty
        ? 0.0
        : (values.last - values.first);
    final isDown = delta < 0;
    final deltaColor = isDown ? AppColors.success : AppColors.warning;
    final deltaSign = isDown ? '' : '+';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  'Tren Berat 5 Minggu Terakhir',
                  style: AppTextStyles.h3.copyWith(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDown
                          ? Icons.trending_down
                          : Icons.trending_up,
                      size: 12,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$deltaSign${delta.toStringAsFixed(1)} kg',
                      style: AppTextStyles.caption.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          // Pakai WeightLineChart reusable dengan X/Y axis labels
          WeightLineChart(
            values: values,
            xLabels: const ['M1', 'M2', 'M3', 'M4', 'M5'],
            height: 160,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MENU TILE — list tile dengan icon + label + chevron
// ═══════════════════════════════════════════════════════════════

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDanger ? AppColors.error : AppColors.primary;
    final textColor = isDanger ? AppColors.error : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.base,
            vertical: AppDimensions.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: textColor,
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
              Icon(
                Icons.chevron_right,
                color: isDanger
                    ? AppColors.error
                    : AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
