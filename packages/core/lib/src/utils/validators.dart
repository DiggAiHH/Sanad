/// Input validators for forms
class Validators {
  Validators._();

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-Mail ist erforderlich';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ungültige E-Mail-Adresse';
    }
    return null;
  }

  /// Validate password with strength requirements
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Passwort ist erforderlich';
    }
    if (value.length < 8) {
      return 'Passwort muss mindestens 8 Zeichen haben';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Passwort muss mindestens einen Großbuchstaben enthalten';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Passwort muss mindestens einen Kleinbuchstaben enthalten';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Passwort muss mindestens eine Zahl enthalten';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Feld'} ist erforderlich';
    }
    return null;
  }

  /// Validate phone number (German format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    final phoneRegex = RegExp(r'^(\+49|0)[1-9]\d{6,14}$');
    final cleaned = value.replaceAll(RegExp(r'[\s\-\/]'), '');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Ungültige Telefonnummer';
    }
    return null;
  }

  /// Validate ticket number format (e.g., A-001)
  static String? ticketNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ticketnummer ist erforderlich';
    }
    final ticketRegex = RegExp(r'^[A-Z]-\d{3}$');
    if (!ticketRegex.hasMatch(value)) {
      return 'Ungültiges Ticketformat (z.B. A-001)';
    }
    return null;
  }

  /// Validate insurance number
  static String? insuranceNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    // German insurance number: 10 characters
    if (value.length != 10) {
      return 'Versicherungsnummer muss 10 Zeichen haben';
    }
    return null;
  }

  /// Validate postal code (German)
  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'PLZ ist erforderlich';
    }
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'Ungültige PLZ';
    }
    return null;
  }
}

