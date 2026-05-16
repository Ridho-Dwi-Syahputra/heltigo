# Frontend — Design System

> 📌 **Brand colors update 2026-05-15** — Warna final sesuai logo:
>
> | Token | Hex | Notes |
> |---|---|---|
> | `AppColors.primary` | `#1D6766` | **Teal** (bukan `#1A6B4A` draft awal) — main accent |
> | `AppColors.primaryMuted` | `#331D6766` | Teal 20% — container bg |
> | `AppColors.accent` | `#FB3A01` | **Orange** — CTA aktif, intensitas tinggi |
> | `AppColors.background` | `#0D0D0D` | Pure dark mode |
> | `AppColors.surface` | `#1A1A1A` | Card |
> | `AppColors.surfaceLight` | `#242424` | Input/elevated |
> | `AppColors.textPrimary` | `#F5F5F5` | Teks utama |
> | `AppColors.textSecondary` | `#B0B0B0` | Teks pendukung |
> | `AppColors.success` | `#22C55E` | |
> | `AppColors.warning` | `#F59E0B` | |
> | `AppColors.info` | `#3B82F6` | |
> | `AppColors.streakPurple` | `#8B5CF6` | Streak/badge |
> | `AppColors.waterBlue` | `#06B6D4` | Hidrasi |
>
> Implementasi aktual ada di `frontend/heltigo/lib/styles/colors.dart` — gunakan tokens dari `AppColors.*` (bukan hardcode hex).
>
> Mode: **Dark only** (tidak ada light mode). Font: **Inter** via `google_fonts`.

---

Sumber: `Heltigo_UI_Screens.docx` §1. Dokumen ini adalah terjemahan ke kode Dart yang akan diimplementasikan di `lib/core/theme/`.

---

## 1. Color Palette — Light Mode

File: `lib/core/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Primary
  static const primary = Color(0xFF1A6B4A);
  static const accent = Color(0xFF34C27A);
  static const primaryLight = Color(0xFFE8F8EF);
  static const primaryExtraLight = Color(0xFFF0FBF5);

  // Energy
  static const energyOrange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFEF3EB);

  // Streak / Achievement
  static const purple = Color(0xFF7F77DD);
  static const purpleLight = Color(0xFFEEEDFE);

  // Warning / Mood Sedang
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFAEEDA);

  // Error
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);

  // Surfaces
  static const background = Color(0xFFFAFAF8);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F2);
  static const border = Color(0xFFE0DED8);

  // Text
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF5F5E5A);
  static const textTertiary = Color(0xFF9C9B98);

  // Dark Mode
  static const darkBackground = Color(0xFF111827);
  static const darkCard = Color(0xFF1F2937);
  static const darkSurface = Color(0xFF374151);
  static const darkPrimary = Color(0xFF4ADE80);
  static const darkOrange = Color(0xFFFB923C);
  static const darkTextPrimary = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
}
```

### Kapan menggunakan setiap warna

| Warna | Use case |
|---|---|
| `primary` (#1A6B4A) | Header, tombol CTA utama, icon aktif navbar, status bar |
| `accent` (#34C27A) | State aktif, indikator sukses, streak badge, progress bar |
| `primaryLight` | Background chip/badge, highlight, selected card border |
| `primaryExtraLight` | Background section header, tinted card surface |
| `energyOrange` | Tombol CTA sekunder, indikator energi tinggi, notif badge |
| `orangeLight` | Background chip orange, latar badge warning |
| `purple` | Streak indicator, badge pencapaian, weekly report accent |
| `purpleLight` | Background streak card |
| `amber` | Peringatan, indikator mood sedang, badge kuning |
| `error` | Pesan error, indikator merah, skor < 50% |
| `background` | Background utama seluruh app (warm off-white) |
| `card` | Background card, bottom sheet, dialog |
| `surface` | Input field background, secondary card |
| `border` | Garis divider, border input, separator list |

---

## 2. Typography

File: `lib/core/theme/app_text_styles.dart`

Font: **Inter** (via `google_fonts: GoogleFonts.inter()`). Fallback: **Poppins**.

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.3,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get numberBold => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1,
      );
}
```

### Mapping ke spec UI

| Spec name | Style |
|---|---|
| Display / Hero | `display` (48sp Bold) |
| H1 — Heading Layar | `h1` (28sp SemiBold, primary) |
| H2 — Heading Seksi | `h2` (22sp SemiBold) |
| H3 — Heading Item | `h3` (18sp SemiBold) |
| Body Large | `bodyLarge` (16sp Regular) |
| Body | `body` (14sp Regular) |
| Body Small | `bodySmall` (13sp Regular) |
| Caption | `caption` (12sp Regular) |
| Label / Badge | `label` (11sp Medium, letter spacing 0.5) |
| Number Bold | `numberBold` (32sp Bold, primary) |

---

## 3. Spacing, Radius & Shadow

File: `lib/core/theme/app_sizes.dart`

```dart
abstract class AppSizes {
  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  // Border Radius
  static const double radiusButton = 24;     // Pill CTA
  static const double radiusCard = 16;
  static const double radiusInput = 12;
  static const double radiusBadge = 20;
  static const double radiusBottomSheetTop = 20;

  // Component Heights
  static const double buttonHeight = 54;
  static const double inputHeight = 56;
  static const double bottomNavHeight = 64;
  static const double appBarHeight = 56;
}

abstract class AppShadows {
  static const cardLight = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x1F000000), // black 12%
    ),
  ];

  static const buttonPrimary = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 12,
      color: Color(0x4D1A6B4A), // primary 30%
    ),
  ];
}
```

---

## 4. ThemeData (Light & Dark)

File: `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_sizes.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.card,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusInput),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusInput),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusInput),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          floatingLabelStyle: AppTextStyles.body.copyWith(color: AppColors.primary),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkOrange,
          surface: AppColors.darkCard,
          error: AppColors.error,
          onPrimary: Colors.black,
          onSurface: AppColors.darkTextPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          ),
        ),
      );
}
```

---

## 5. Komponen Reusable

File: `lib/shared/widgets/`

### 5.1 PrimaryButton

```dart
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          boxShadow: onPressed == null ? null : AppShadows.buttonPrimary,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusButton),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: AppSizes.sm),
                    ],
                    Text(label, style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                  ],
                ),
        ),
      ),
    );
  }
}
```

Use case: `'Buat Rencana Saya'`, `'Mulai Latihan'`, `'Simpan'`, `'Lanjutkan'`.

### 5.2 SecondaryButton

```dart
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
        ),
        child: Text(label, style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        )),
      ),
    );
  }
}
```

### 5.3 HeltigoCard

```dart
class HeltigoCard extends StatelessWidget {
  const HeltigoCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.base),
    this.margin = const EdgeInsets.symmetric(horizontal: AppSizes.base, vertical: AppSizes.sm),
    this.color,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: AppShadows.cardLight,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      child: card,
    );
  }
}
```

### 5.4 InputField

```dart
class InputField extends StatelessWidget {
  const InputField({
    required this.label,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffix: suffix,
      ),
    );
  }
}
```

### 5.5 StatusChip

```dart
enum StatusChipVariant { success, active, achievement, danger }

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.variant,
    super.key,
  });
  final String label;
  final StatusChipVariant variant;

  Color get _bgColor {
    switch (variant) {
      case StatusChipVariant.success: return AppColors.primaryLight;
      case StatusChipVariant.active: return AppColors.orangeLight;
      case StatusChipVariant.achievement: return AppColors.purpleLight;
      case StatusChipVariant.danger: return AppColors.errorLight;
    }
  }

  Color get _fgColor {
    switch (variant) {
      case StatusChipVariant.success: return AppColors.primary;
      case StatusChipVariant.active: return AppColors.energyOrange;
      case StatusChipVariant.achievement: return AppColors.purple;
      case StatusChipVariant.danger: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusBadge),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(color: _fgColor)),
    );
  }
}
```

---

## 6. Aturan Penggunaan

1. **Selalu pakai `AppColors`, `AppSizes`, `AppTextStyles`** — tidak boleh hardcode `Color(0xFF...)` atau `fontSize: 16` di widget.
2. **Komponen reusable** wajib dipakai untuk konsistensi: jangan buat tombol custom untuk satu layar saja kecuali variant yang sangat berbeda.
3. **Dark mode**: pakai `Theme.of(context).colorScheme.*` di mana memungkinkan, atau cek `MediaQuery.of(context).platformBrightness` untuk pilih light/dark variant.
4. **Padding standar layar**: `EdgeInsets.symmetric(horizontal: AppSizes.base)` (16px kiri-kanan).
5. **Spacing antar section**: `AppSizes.xl` (24px) atau `AppSizes.xxl` (32px) untuk pemisah besar.
6. **Animasi**: durasi default 200ms (`Curves.easeOut`), 300ms untuk transisi route, 600ms untuk Lottie celebration.

---

## 7. Aset Visual

Disimpan di `assets/`:

- `assets/lottie/splash.json` — animasi logo splash 2.5 detik
- `assets/lottie/ai_processing.json` — otak/AI berputar partikel hijau (S-13)
- `assets/lottie/celebration.json` — konfeti workout complete (S-21, S-14, S-35)
- `assets/lottie/empty_box.json` — empty state
- `assets/images/onboarding_1.png` — orang olahraga + grafik AI (S-02)
- `assets/images/onboarding_2.png` — makanan lokal Indonesia + koin (S-03)
- `assets/images/onboarding_3.png` — perisai/kunci hijau + smartphone (S-04)
- `assets/images/logo.png` — logo Heltigo

Sumber Lottie gratis: <https://lottiefiles.com>. Pilih license CC0 atau CC-BY untuk asset.
Sumber illustration onboarding: <https://undraw.co> atau <https://storyset.com> (free + brandable).
