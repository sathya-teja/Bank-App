class Validators {
  static String? notEmpty(String? v, {String field = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  static String? minLen(String? v, int len, {String field = 'Field'}) {
    if (v == null || v.trim().length < len) return '$field must be at least $len characters';
    return null;
  }
}
