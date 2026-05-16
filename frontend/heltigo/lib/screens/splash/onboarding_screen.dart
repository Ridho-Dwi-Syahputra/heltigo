/// S-02: Onboarding Screen — carousel 3 halaman perkenalan fitur
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-02
/// Navigasi: → login (Get Started) atau → login (Skip)
///
/// Layout sesuai referensi gambar:
/// - Gambar di bagian atas (60% layar) dengan fade-to-black overlay
/// - Judul fitur & deskripsi di bawah gambar
/// - Page indicators (dot) di tengah
/// - Tombol "Next" / "Get Started" di bawah
/// - Link "Already have an account? Sign In" di halaman terakhir
/// - Tombol "Skip" di kanan atas
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data 3 halaman onboarding
  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      imagePath: 'assets/screen/onboarding/onboarding 1.jpg',
      title: 'Latihan Terbaik\nUntuk Kamu',
      description:
          'AI kami menganalisis profil, kondisi fisik, dan tujuan kesehatanmu '
          'untuk merekomendasikan program latihan yang benar-benar personal — '
          'bukan template, tapi rencana yang dirancang khusus untukmu.',
    ),
    _OnboardingData(
      imagePath: 'assets/screen/onboarding/onboarding 2.jpg',
      title: 'Nutrisi Cerdas\nSesuai Budget',
      description:
          'Dapatkan rekomendasi menu makanan sehat yang disesuaikan dengan '
          'anggaran harianmu. Tidak perlu mahal untuk hidup sehat — '
          'AI kami menemukan opsi terbaik di sekitarmu.',
    ),
    _OnboardingData(
      imagePath: 'assets/screen/onboarding/onboarding 3.jpg',
      title: 'AI Mengatur\nProgress Mingguan',
      description:
          'Setiap minggu, AI menganalisis progress latihanmu dan secara otomatis '
          'menyesuaikan jadwal serta intensitas. Semakin kamu berlatih, '
          'semakin pintar rekomendasinya.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tinggi area bottom: dots + spacing + button + sign-in (opsional) + safe.
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    // Reserve: dots (10) + xl spacing + button + base padding + opsional sign-in row (~46) + bottomSafe + xxl
    final reservedBottom =
        10 + AppDimensions.xl + AppDimensions.buttonHeight +
            (_currentPage == _pages.length - 1 ? 46 : 0) +
            AppDimensions.xxl + bottomSafe;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ═══════════════════════════════════════
          // PAGE VIEW — gambar + konten
          // ═══════════════════════════════════════
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                bottomReservedHeight: reservedBottom,
              );
            },
          ),

          // ═══════════════════════════════════════
          // SKIP BUTTON — kanan atas
          // ═══════════════════════════════════════
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: AppDimensions.screenPaddingH,
            child: TextButton(
              onPressed: _goToLogin,
              child: Text(
                'Skip',
                style: AppTextStyles.link,
              ),
            ),
          ),

          // ═══════════════════════════════════════
          // BOTTOM SECTION — indicators + button + sign in
          // ═══════════════════════════════════════
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x000D0D0D),
                    Color(0xFF0D0D0D),
                  ],
                  stops: [0.0, 0.35],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH,
                AppDimensions.lg,
                AppDimensions.screenPaddingH,
                bottomSafe + AppDimensions.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators (dots)
                  _PageIndicator(
                    count: _pages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),

                  // Sign In link (hanya di halaman terakhir)
                  AnimatedOpacity(
                    opacity: _currentPage == _pages.length - 1 ? 1.0 : 0.0,
                    duration: AppDurations.fast,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.base),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.body,
                          ),
                          GestureDetector(
                            onTap: _goToLogin,
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.link,
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
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════

class _OnboardingData {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

// ═══════════════════════════════════════════════════════════════
// ONBOARDING PAGE — satu halaman penuh
// ═══════════════════════════════════════════════════════════════

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  /// Tinggi area bottom (indicator + button + bottom safe area) supaya text
  /// section tidak overlap dengan tombol di bawah.
  final double bottomReservedHeight;

  const _OnboardingPage({
    required this.data,
    required this.bottomReservedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        // Image scale: 55% untuk layar besar, turun jadi 45% untuk layar kecil
        // supaya teks tetap kebaca.
        final imageRatio = screenHeight < 700 ? 0.42 : 0.50;
        final imageHeight = screenHeight * imageRatio;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════
            // GAMBAR — dengan gradient overlay ke bawah
            // ═══════════════════════════════════════
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00000000),
                          Color(0x330D0D0D),
                          Color(0xCC0D0D0D),
                          Color(0xFF0D0D0D),
                        ],
                        stops: [0.0, 0.5, 0.75, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // TEKS — scrollable bila kurang ruang
            // ═══════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPaddingH,
                  AppDimensions.lg,
                  AppDimensions.screenPaddingH,
                  bottomReservedHeight + AppDimensions.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.onboardingTitle,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      data.description,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.onboardingDesc,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE INDICATOR — dot indicators
// ═══════════════════════════════════════════════════════════════

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dotSpacing / 2,
          ),
          width: isActive ? AppDimensions.dotActiveWidth : AppDimensions.dotSize,
          height: AppDimensions.dotSize,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.textTertiary,
            borderRadius: BorderRadius.circular(AppDimensions.dotSize / 2),
          ),
        );
      }),
    );
  }
}
