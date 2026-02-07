import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_voice/src/localization/supported_languages.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_de.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_en.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_ar.dart';

void main() {
  group('SupportedLanguage', () {
    test('has all 16 languages', () {
      expect(SupportedLanguage.values.length, 16);
    });

    test('phase1 has 4 languages', () {
      expect(SupportedLanguage.phase1.length, 4);
      expect(SupportedLanguage.phase1, contains(SupportedLanguage.german));
      expect(SupportedLanguage.phase1, contains(SupportedLanguage.english));
      expect(SupportedLanguage.phase1, contains(SupportedLanguage.turkish));
      expect(SupportedLanguage.phase1, contains(SupportedLanguage.arabic));
    });

    test('phase2 has 4 languages', () {
      expect(SupportedLanguage.phase2.length, 4);
    });

    test('phase3 has 5 languages', () {
      expect(SupportedLanguage.phase3.length, 5);
    });

    test('phase4 has 3 languages', () {
      expect(SupportedLanguage.phase4.length, 3);
    });

    test('fromCode returns correct language', () {
      expect(SupportedLanguage.fromCode('de-DE'), SupportedLanguage.german);
      expect(SupportedLanguage.fromCode('en-GB'), SupportedLanguage.english);
      expect(SupportedLanguage.fromCode('ar-SA'), SupportedLanguage.arabic);
    });

    test('fromCode is case insensitive', () {
      expect(SupportedLanguage.fromCode('DE-de'), SupportedLanguage.german);
    });

    test('fromCode returns null for unknown', () {
      expect(SupportedLanguage.fromCode('xx-XX'), isNull);
    });

    test('isRTL is true for Arabic, Farsi, Urdu', () {
      expect(SupportedLanguage.arabic.isRTL, isTrue);
      expect(SupportedLanguage.farsi.isRTL, isTrue);
      expect(SupportedLanguage.urdu.isRTL, isTrue);
    });

    test('isRTL is false for LTR languages', () {
      expect(SupportedLanguage.german.isRTL, isFalse);
      expect(SupportedLanguage.english.isRTL, isFalse);
      expect(SupportedLanguage.russian.isRTL, isFalse);
    });

    test('shortCode extracts language code', () {
      expect(SupportedLanguage.german.shortCode, 'de');
      expect(SupportedLanguage.english.shortCode, 'en');
    });

    test('has valid flags', () {
      for (final lang in SupportedLanguage.values) {
        expect(lang.flag, isNotEmpty);
        expect(lang.flag.length, greaterThanOrEqualTo(2));
      }
    });
  });

  group('SupportedLanguages', () {
    test('getStrings returns German strings for de', () {
      final strings = SupportedLanguages.getStrings('de');
      expect(strings, isA<VoiceStringsDe>());
      expect(strings.languageCode, 'de');
    });

    test('getStrings returns English strings for en', () {
      final strings = SupportedLanguages.getStrings('en');
      expect(strings, isA<VoiceStringsEn>());
      expect(strings.languageCode, 'en');
    });

    test('getStrings handles locale format (de-DE)', () {
      final strings = SupportedLanguages.getStrings('de-DE');
      expect(strings.languageCode, 'de');
    });

    test('getStrings falls back to English for unknown', () {
      final strings = SupportedLanguages.getStrings('xx');
      expect(strings, isA<VoiceStringsEn>());
    });

    test('getTtsLocale returns correct locale', () {
      expect(SupportedLanguages.getTtsLocale('de-DE'), 'de-DE');
      expect(SupportedLanguages.getTtsLocale('en-GB'), 'en-GB');
      expect(SupportedLanguages.getTtsLocale('de'), 'de-DE');
      expect(SupportedLanguages.getTtsLocale('en'), 'en-GB');
    });

    test('isSupported returns true for valid codes', () {
      expect(SupportedLanguages.isSupported('de-DE'), isTrue);
      expect(SupportedLanguages.isSupported('en-GB'), isTrue);
      expect(SupportedLanguages.isSupported('ar-SA'), isTrue);
      expect(SupportedLanguages.isSupported('de'), isTrue);
      expect(SupportedLanguages.isSupported('ar'), isTrue);
    });

    test('isSupported returns false for invalid codes', () {
      expect(SupportedLanguages.isSupported('xx-XX'), isFalse);
    });

    test('isRTL returns true for RTL languages', () {
      expect(SupportedLanguages.isRTL('ar-SA'), isTrue);
      expect(SupportedLanguages.isRTL('fa-IR'), isTrue);
      expect(SupportedLanguages.isRTL('ar'), isTrue);
    });

    test('isRTL returns false for LTR languages', () {
      expect(SupportedLanguages.isRTL('de-DE'), isFalse);
    });

    test('defaultLanguage is German', () {
      expect(SupportedLanguages.defaultLanguage, 'de');
    });
  });
}
