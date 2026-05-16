/// S-03: Login Screen — halaman masuk pengguna
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-03
/// API: POST /auth/login
///
/// Layout:
/// - Logo Heltigo (logo_with_tulisan.png) di atas
/// - Judul "Masuk" + subtitle
/// - Form email + password
/// - Lupa Password link
/// - Tombol Masuk (primary teal)
/// - Link ke Register
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = (screenWidth * 0.35).clamp(120.0, 160.0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // ═══════════════════════════════════════
                // LOGO HELTIGO
                // ═══════════════════════════════════════
                Center(
                  child: Image.asset(
                    'assets/logo/logo_with_tulisan.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // ═══════════════════════════════════════
                // JUDUL
                // ═══════════════════════════════════════
                Text('Masuk', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'Masuk ke akun Heltigo kamu',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // ═══════════════════════════════════════
                // EMAIL FIELD
                // ═══════════════════════════════════════
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ═══════════════════════════════════════
                // PASSWORD FIELD
                // ═══════════════════════════════════════
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // ═══════════════════════════════════════
                // LUPA PASSWORD
                // ═══════════════════════════════════════
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Lupa Password?',
                      style: AppTextStyles.link.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ═══════════════════════════════════════
                // TOMBOL MASUK
                // ═══════════════════════════════════════
                SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Implementasi login via AuthProvider
                        context.go('/home');
                      }
                    },
                    child: const Text('Masuk'),
                  ),
                ),
                const SizedBox(height: 24),

                // ═══════════════════════════════════════
                // REGISTER LINK
                // ═══════════════════════════════════════
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: AppTextStyles.body,
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Daftar',
                        style: AppTextStyles.link,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
