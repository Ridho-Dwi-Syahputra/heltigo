/// Food Scan Screen — AI-powered food recognition via camera/gallery
/// Flow: Ambil foto → Kirim ke FastAPI /predict/food-scan → Tampilkan nutrisi
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../styles/styles.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  final _picker = ImagePicker();

  File? _imageFile;
  bool _isAnalyzing = false;
  _ScanResult? _result;

  // ─── Pick image ───────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (xFile != null) _analyzeImage(File(xFile.path));
  }

  Future<void> _pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (xFile != null) _analyzeImage(File(xFile.path));
  }

  // ─── Analyze ──────────────────────────────────────────────────
  Future<void> _analyzeImage(File file) async {
    setState(() {
      _imageFile = file;
      _isAnalyzing = true;
      _result = null;
    });

    // TODO: Kirim ke FastAPI /predict/food-scan dengan base64 image
    // Sementara pakai mock result setelah delay
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _result = _ScanResult(
        identifiedFoods: const ['Nasi putih', 'Ayam goreng', 'Sayur kangkung'],
        matches: const [
          _FoodMatch(name: 'Nasi putih',     calories: 242, protein: 4.4,  fat: 0.4, carbs: 53.4, confidence: 0.94),
          _FoodMatch(name: 'Ayam goreng',    calories: 298, protein: 25.1, fat: 18.7, carbs: 7.8,  confidence: 0.89),
          _FoodMatch(name: 'Sayur kangkung', calories: 28,  protein: 3.0,  fat: 0.3,  carbs: 4.2,  confidence: 0.87),
        ],
        totalCalories: 568,
        totalProtein: 32.5,
        totalFat: 19.4,
        totalCarbs: 65.4,
        assessment: 'MODERATE',
        healthScore: 0.65,
      );
    });
  }

  void _reset() => setState(() {
        _imageFile = null;
        _isAnalyzing = false;
        _result = null;
      });

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Makanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _imageFile == null
            ? _buildPicker(context)
            : _buildResult(context),
      ),
    );
  }

  // ─── Picker view ──────────────────────────────────────────────
  Widget _buildPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.lg),

          // Illustration
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  'Foto makananmu',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'AI akan mengenali makanan dan\nmenghitung kalori otomatis',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          // AI badge
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    'Menggunakan Gemini Vision AI + database 1.346+ makanan Indonesia',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Buttons
          ElevatedButton.icon(
            onPressed: _pickFromCamera,
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
            label: const Text('Buka Kamera'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text('Pilih dari Galeri'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
        ],
      ),
    );
  }

  // ─── Result view ──────────────────────────────────────────────
  Widget _buildResult(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.base),
      children: [
        // Image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Image.file(
            _imageFile!,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppDimensions.base),

        if (_isAnalyzing) ...[
          const SizedBox(height: AppDimensions.lg),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.md),
          Center(
            child: Text(
              'AI sedang menganalisis makananmu...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ] else if (_result != null) ...[
          _buildAssessmentBadge(_result!),
          const SizedBox(height: AppDimensions.base),
          _buildNutritionCard(_result!),
          const SizedBox(height: AppDimensions.base),
          _buildFoodMatchList(_result!),
          const SizedBox(height: AppDimensions.xl),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Scan Makanan Lain'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
        ],
      ],
    );
  }

  Widget _buildAssessmentBadge(_ScanResult result) {
    final (color, icon, label) = switch (result.assessment) {
      'GOOD'     => (AppColors.success, Icons.check_circle_outline, 'Pilihan Bagus!'),
      'POOR'     => (AppColors.error,   Icons.warning_amber_outlined, 'Perlu Diperhatikan'),
      _          => (AppColors.warning, Icons.info_outline, 'Cukup Seimbang'),
    };

    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Skor nutrisi: ${(result.healthScore * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(_ScanResult result) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Nutrisi', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _NutrientBox(
                label: 'Kalori',
                value: '${result.totalCalories}',
                unit: 'kkal',
                color: AppColors.accent,
              ),
              const SizedBox(width: AppDimensions.sm),
              _NutrientBox(
                label: 'Protein',
                value: result.totalProtein.toStringAsFixed(1),
                unit: 'g',
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.sm),
              _NutrientBox(
                label: 'Karbo',
                value: result.totalCarbs.toStringAsFixed(1),
                unit: 'g',
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.sm),
              _NutrientBox(
                label: 'Lemak',
                value: result.totalFat.toStringAsFixed(1),
                unit: 'g',
                color: AppColors.streakPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodMatchList(_ScanResult result) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fastfood_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppDimensions.sm),
              Text('Makanan Terdeteksi', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...result.matches.asMap().entries.map((e) {
            final isLast = e.key == result.matches.length - 1;
            final m = e.value;
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.restaurant_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            '${m.calories} kkal · P:${m.protein.toStringAsFixed(1)}g · L:${m.fat.toStringAsFixed(1)}g · K:${m.carbs.toStringAsFixed(1)}g',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        '${(m.confidence * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: AppDimensions.sm),
                  const Divider(height: 1),
                  const SizedBox(height: AppDimensions.sm),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Nutrient box ──────────────────────────────────────────────
class _NutrientBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutrientBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              unit,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data models ───────────────────────────────────────────────
class _ScanResult {
  final List<String> identifiedFoods;
  final List<_FoodMatch> matches;
  final int totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;
  final String assessment; // GOOD | MODERATE | POOR
  final double healthScore;

  const _ScanResult({
    required this.identifiedFoods,
    required this.matches,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
    required this.assessment,
    required this.healthScore,
  });
}

class _FoodMatch {
  final String name;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final double confidence;

  const _FoodMatch({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.confidence,
  });
}
