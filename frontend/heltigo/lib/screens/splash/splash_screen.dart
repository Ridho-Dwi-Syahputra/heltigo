/// S-01: Splash Screen — tampilan awal aplikasi
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-01
/// Navigasi: → onboarding (first time) atau home (sudah login)
///
/// Fitur:
/// - Logo Heltigo (logo_with_tulisan.png) dengan animasi fade-in + scale
/// - Motto aplikasi di bawah logo
/// - Auto-navigate ke onboarding setelah splash tampil cukup lama
/// - Dark background solid
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _mottoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _mottoFade;
  late Animation<Offset> _mottoSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // === LOGO ANIMATION (800ms) ===
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // === MOTTO ANIMATION (600ms, mulai setelah logo) ===
    _mottoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _mottoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mottoController, curve: Curves.easeIn),
    );

    _mottoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mottoController, curve: Curves.easeOut),
    );
  }

  void _startSequence() {
    // Langsung mulai animasi logo (tanpa postFrameCallback delay)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _logoController.forward();
    });

    // Motto muncul 500ms setelah logo mulai
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _mottoController.forward();
    });

    // Navigate ke onboarding setelah 3.5 detik total
    // (cukup lama untuk user melihat logo + motto dengan nyaman)
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      // TODO: Cek auth state → arahkan ke /onboarding atau /home
      context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _mottoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive: logo width = 45% layar, min 140 max 220
    final logoWidth = (screenWidth * 0.45).clamp(140.0, 220.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ═══════════════════════════════════════
            // LOGO — fade in + scale up
            // ═══════════════════════════════════════
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/logo/logo_with_tulisan.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 28),

            // ═══════════════════════════════════════
            // MOTTO — slide up + fade in
            // ═══════════════════════════════════════
            SlideTransition(
              position: _mottoSlide,
              child: FadeTransition(
                opacity: _mottoFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingH,
                  ),
                  child: Text(
                    'Your AI-Powered Health & Fitness Partner',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.motto,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
