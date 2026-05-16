/// Form Validators — validasi input user
/// Sumber: docs/frontend/05_SCREENS_SPEC.md (auth screens)
class Validators {
  /// Validasi email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  /// Validasi password
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  /// Validasi nama
  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Nama wajib diisi';
    if (value.length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  /// Validasi angka
  static String? number(String? value, {String label = 'Field'}) {
    if (value == null || value.isEmpty) return '$label wajib diisi';
    if (double.tryParse(value) == null) return '$label harus berupa angka';
    return null;
  }

  /// Validasi field tidak boleh kosong
  static String? required(String? value, {String label = 'Field'}) {
    if (value == null || value.isEmpty) return '$label wajib diisi';
    return null;
  }
}
