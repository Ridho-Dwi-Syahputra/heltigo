/// S-05: Forgot Password Screen — reset password via email
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-05
///
/// Layout:
/// - State 1 (form): logo + form email + tombol Kirim
/// - State 2 (sent): icon besar + pesan success + tombol Kembali
/// - Bottom link "Ingat password? Masuk"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      // TODO: Integrate with AuthProvider.forgotPassword()
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = (screenWidth * 0.3).clamp(100.0, 140.0);

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
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: _emailSent
              ? _SuccessView(email: _emailController.text)
              : _FormView(
                  formKey: _formKey,
                  emailController: _emailController,
                  logoWidth: logoWidth,
                  onSend: _handleSend,
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FORM VIEW — state awal
// ═══════════════════════════════════════════════════════════════

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final double logoWidth;
  final VoidCallback onSend;

  const _FormView({
    required this.formKey,
    required this.emailController,
    required this.logoWidth,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.lg),

          // Logo
          Center(
            child: Image.asset(
              'assets/logo/logo_with_tulisan.png',
              width: logoWidth,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),

          // Title
          Text('Lupa Password?', style: AppTextStyles.h1),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Masukkan email kamu untuk menerima link reset password.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),

          // Email field
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primary,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
            onFieldSubmitted: (_) => onSend(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.xl),

          // Send button
          SizedBox(
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              onPressed: onSend,
              child: const Text('Kirim Link Reset'),
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Back to login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ingat password? ', style: AppTextStyles.body),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  'Masuk',
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SUCCESS VIEW — setelah email dikirim
// ═══════════════════════════════════════════════════════════════

class _SuccessView extends StatelessWidget {
  final String email;

  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimensions.xxxl),

        // Success Icon dengan glow background
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryMuted,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 56,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.xl),

        // Title
        Text(
          'Email Terkirim!',
          textAlign: TextAlign.center,
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: AppDimensions.md),

        // Subtitle
        Text(
          'Kami sudah mengirim link reset password ke',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          email,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Cek inbox atau folder spam kamu untuk melanjutkan.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppDimensions.xxxl),

        // Back button
        SizedBox(
          height: AppDimensions.buttonHeight,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Kembali ke Masuk'),
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
      ],
    );
  }
}
