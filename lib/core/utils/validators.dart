/// Robust enterprise form validators with clear error messaging.
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp _phoneRegExp = RegExp(
    r'^[+]?[\d\s\-().]{7,25}$',
  );

  static String? required(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 60) {
      return 'Name cannot exceed 60 characters';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Work email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Enter a valid corporate email (e.g. name@company.com)';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final trimmed = value.trim();
    if (!_phoneRegExp.hasMatch(trimmed) || trimmed.replaceAll(RegExp(r'\D'), '').length < 7) {
      return 'Enter a valid phone number (e.g. +1 555-0192)';
    }
    return null;
  }

  static String? employeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee ID is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Employee ID is too short';
    }
    return null;
  }

  static String? designation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Job designation is required';
    }
    if (value.trim().length < 2) {
      return 'Designation must be at least 2 characters';
    }
    return null;
  }
}
