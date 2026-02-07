import 'voice_strings.dart';
import 'strings/voice_strings_de.dart';
import 'strings/voice_strings_en.dart';
import 'strings/voice_strings_tr.dart';
import 'strings/voice_strings_ar.dart';
import 'strings/voice_strings_ru.dart';
import 'strings/voice_strings_pl.dart';
import 'strings/voice_strings_fr.dart';
import 'strings/voice_strings_es.dart';
import 'strings/voice_strings_it.dart';
import 'strings/voice_strings_pt.dart';
import 'strings/voice_strings_uk.dart';
import 'strings/voice_strings_fa.dart';
import 'strings/voice_strings_ur.dart';
import 'strings/voice_strings_vi.dart';
import 'strings/voice_strings_ro.dart';
import 'strings/voice_strings_el.dart';

/// Supported languages for voice features
enum SupportedLanguage {
  // Phase 1 (P0) - MVP
  german('de-DE', 'Deutsch', 'German', '🇩🇪'),
  english('en-GB', 'Englisch', 'English', '🇬🇧'),
  turkish('tr-TR', 'Türkisch', 'Turkish', '🇹🇷'),
  arabic('ar-SA', 'Arabisch', 'Arabic', '🇸🇦'),
  
  // Phase 2 (P1)
  russian('ru-RU', 'Russisch', 'Russian', '🇷🇺'),
  polish('pl-PL', 'Polnisch', 'Polish', '🇵🇱'),
  french('fr-FR', 'Französisch', 'French', '🇫🇷'),
  spanish('es-ES', 'Spanisch', 'Spanish', '🇪🇸'),
  
  // Phase 3 (P2)
  italian('it-IT', 'Italienisch', 'Italian', '🇮🇹'),
  portuguese('pt-PT', 'Portugiesisch', 'Portuguese', '🇵🇹'),
  ukrainian('uk-UA', 'Ukrainisch', 'Ukrainian', '🇺🇦'),
  farsi('fa-IR', 'Farsi', 'Farsi/Persian', '🇮🇷'),
  urdu('ur-PK', 'Urdu', 'Urdu', '🇵🇰'),
  
  // Phase 4 (P3)
  vietnamese('vi-VN', 'Vietnamesisch', 'Vietnamese', '🇻🇳'),
  romanian('ro-RO', 'Rumänisch', 'Romanian', '🇷🇴'),
  greek('el-GR', 'Griechisch', 'Greek', '🇬🇷');

  final String code;
  final String nameDE;
  final String nameEN;
  final String flag;

  const SupportedLanguage(this.code, this.nameDE, this.nameEN, this.flag);

  /// Display name (defaults to German UI)
  String get name => nameDE;

  /// Check if language is right-to-left
  bool get isRTL => this == arabic || this == farsi || this == urdu;
  
  /// Get short code (e.g., 'de' from 'de-DE')
  String get shortCode => code.split('-').first;

  /// Get VoiceStrings instance
  VoiceStrings get strings => SupportedLanguages.getStrings(shortCode);

  /// Get language by code
  static SupportedLanguage? fromCode(String code) {
    final normalized = code.trim();
    if (normalized.isEmpty) return null;

    try {
      return values.firstWhere(
        (lang) {
          final lc = normalized.toLowerCase();
          return lang.code.toLowerCase() == lc || lang.shortCode.toLowerCase() == lc;
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Get Phase 1 (MVP) languages
  static List<SupportedLanguage> get phase1 => [german, english, turkish, arabic];

  /// Get Phase 2 languages
  static List<SupportedLanguage> get phase2 => [russian, polish, french, spanish];

  /// Get Phase 3 languages
  static List<SupportedLanguage> get phase3 => [
        italian,
        portuguese,
        ukrainian,
        farsi,
        urdu,
      ];

  /// Get Phase 4 languages
  static List<SupportedLanguage> get phase4 => [vietnamese, romanian, greek];

  /// Get all available languages
  static List<SupportedLanguage> get all => values;
}

/// Helper class for language utilities
class SupportedLanguages {
  SupportedLanguages._();

  static const String defaultLanguage = 'de';

  /// Get VoiceStrings for a language code
  static VoiceStrings getStrings(String languageCode) {
    final code = languageCode.split('-').first.toLowerCase();

    switch (code) {
      case 'de':
        return const VoiceStringsDe();
      case 'en':
        return const VoiceStringsEn();
      case 'tr':
        return const VoiceStringsTr();
      case 'ar':
        return const VoiceStringsAr();
      case 'ru':
        return const VoiceStringsRu();
      case 'pl':
        return const VoiceStringsPl();
      case 'fr':
        return const VoiceStringsFr();
      case 'es':
        return const VoiceStringsEs();
      case 'it':
        return const VoiceStringsIt();
      case 'pt':
        return const VoiceStringsPt();
      case 'uk':
        return const VoiceStringsUk();
      case 'fa':
        return const VoiceStringsFa();
      case 'ur':
        return const VoiceStringsUr();
      case 'vi':
        return const VoiceStringsVi();
      case 'ro':
        return const VoiceStringsRo();
      case 'el':
        return const VoiceStringsEl();
      default:
        return const VoiceStringsEn(); // Fallback
    }
  }

  /// Get TTS locale string
  static String getTtsLocale(String languageCode) {
    final lang = SupportedLanguage.fromCode(languageCode);
    return lang?.code ?? 'en-GB';
  }

  /// Check if language is supported
  static bool isSupported(String languageCode) {
    return SupportedLanguage.fromCode(languageCode) != null;
  }

  /// Check if language is RTL
  static bool isRTL(String languageCode) {
    return SupportedLanguage.fromCode(languageCode)?.isRTL ?? false;
  }

  /// Get all languages with metadata
  static List<SupportedLanguage> get all => SupportedLanguage.all;
}
