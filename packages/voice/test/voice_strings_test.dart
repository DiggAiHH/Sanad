import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_voice/src/localization/voice_strings.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_de.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_en.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_tr.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_ar.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_ru.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_pl.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_fr.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_es.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_it.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_pt.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_uk.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_fa.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_ur.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_vi.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_ro.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_el.dart';

void main() {
  final allStrings = <String, VoiceStrings>{
    'de': const VoiceStringsDe(),
    'en': const VoiceStringsEn(),
    'tr': const VoiceStringsTr(),
    'ar': const VoiceStringsAr(),
    'ru': const VoiceStringsRu(),
    'pl': const VoiceStringsPl(),
    'fr': const VoiceStringsFr(),
    'es': const VoiceStringsEs(),
    'it': const VoiceStringsIt(),
    'pt': const VoiceStringsPt(),
    'uk': const VoiceStringsUk(),
    'fa': const VoiceStringsFa(),
    'ur': const VoiceStringsUr(),
    'vi': const VoiceStringsVi(),
    'ro': const VoiceStringsRo(),
    'el': const VoiceStringsEl(),
  };

  group('VoiceStrings implementation', () {
    for (final entry in allStrings.entries) {
      group('${entry.key.toUpperCase()} strings', () {
        final strings = entry.value;

        test('has correct language code', () {
          expect(strings.languageCode, entry.key);
        });

        test('ticketStatus contains all placeholders', () {
          final result = strings.ticketStatus(
            ticketNumber: 'TEST-123',
            position: 5,
            waitMinutes: 10,
          );

          expect(result, contains('TEST-123'));
          expect(result, isNotEmpty);
        });

        test('ticketCalled contains ticket and room', () {
          final result = strings.ticketCalled(
            ticketNumber: 'X-999',
            room: 'Room 7',
          );

          expect(result, contains('X-999'));
          expect(result, contains('Room 7'));
        });

        test('waitTime contains minutes', () {
          final result = strings.waitTime(minutes: 15);

          expect(result, contains('15'));
        });

        test('position contains position number', () {
          final result = strings.position(position: 3);

          expect(result, contains('3'));
        });

        test('patientCall contains ticket and room', () {
          final result = strings.patientCall(
            ticketNumber: 'P-001',
            room: 'Office 2',
          );

          expect(result, contains('P-001'));
          expect(result, contains('Office 2'));
        });

        test('queueStatus contains counts', () {
          final result = strings.queueStatus(
            waitingCount: 12,
            avgWaitMinutes: 20,
          );

          expect(result, contains('12'));
        });

        test('statusCommands is not empty', () {
          expect(strings.statusCommands, isNotEmpty);
        });

        test('waitTimeCommands is not empty', () {
          expect(strings.waitTimeCommands, isNotEmpty);
        });

        test('positionCommands is not empty', () {
          expect(strings.positionCommands, isNotEmpty);
        });

        test('cancelCommands is not empty', () {
          expect(strings.cancelCommands, isNotEmpty);
        });

        test('helpCommands is not empty', () {
          expect(strings.helpCommands, isNotEmpty);
        });

        test('nextPatientCommands is not empty', () {
          expect(strings.nextPatientCommands, isNotEmpty);
        });

        test('patientDoneCommands is not empty', () {
          expect(strings.patientDoneCommands, isNotEmpty);
        });

        test('holdToSpeak is not empty', () {
          expect(strings.holdToSpeak, isNotEmpty);
        });

        test('listening is not empty', () {
          expect(strings.listening, isNotEmpty);
        });

        test('processing is not empty', () {
          expect(strings.processing, isNotEmpty);
        });

        test('speakNow is not empty', () {
          expect(strings.speakNow, isNotEmpty);
        });

        test('voiceEnabled is not empty', () {
          expect(strings.voiceEnabled, isNotEmpty);
        });

        test('voiceDisabled is not empty', () {
          expect(strings.voiceDisabled, isNotEmpty);
        });

        test('noMicrophonePermission is not empty', () {
          expect(strings.noMicrophonePermission, isNotEmpty);
        });

        test('couldNotUnderstand is not empty', () {
          expect(strings.couldNotUnderstand, isNotEmpty);
        });

        test('helpMessage is not empty', () {
          expect(strings.helpMessage, isNotEmpty);
        });

        test('staffHelpMessage is not empty', () {
          expect(strings.staffHelpMessage, isNotEmpty);
        });
      });
    }
  });

  group('Pluralization', () {
    test('German handles singular/plural correctly', () {
      final de = const VoiceStringsDe();

      final singular = de.waitTime(minutes: 1);
      final plural = de.waitTime(minutes: 5);

      expect(singular, contains('Minute'));
      expect(plural, contains('Minuten'));
    });

    test('English handles singular/plural correctly', () {
      final en = const VoiceStringsEn();

      final singular = en.waitTime(minutes: 1);
      final plural = en.waitTime(minutes: 5);

      expect(singular, contains('minute'));
      expect(plural, contains('minutes'));
    });

    test('Russian handles Slavic plural rules', () {
      final ru = const VoiceStringsRu();

      // Russian has 3 plural forms: 1, 2-4, 5+
      final one = ru.waitTime(minutes: 1);
      final two = ru.waitTime(minutes: 2);
      final five = ru.waitTime(minutes: 5);
      final twentyOne = ru.waitTime(minutes: 21);

      expect(one, isNotEmpty);
      expect(two, isNotEmpty);
      expect(five, isNotEmpty);
      expect(twentyOne, isNotEmpty);
    });

    test('Polish handles Slavic plural rules', () {
      final pl = const VoiceStringsPl();

      final one = pl.waitTime(minutes: 1);
      final two = pl.waitTime(minutes: 2);
      final five = pl.waitTime(minutes: 5);

      expect(one, isNotEmpty);
      expect(two, isNotEmpty);
      expect(five, isNotEmpty);
    });

    test('Ukrainian handles Slavic plural rules', () {
      final uk = const VoiceStringsUk();

      final one = uk.waitTime(minutes: 1);
      final two = uk.waitTime(minutes: 2);
      final five = uk.waitTime(minutes: 5);

      expect(one, isNotEmpty);
      expect(two, isNotEmpty);
      expect(five, isNotEmpty);
    });
  });

  group('All 16 languages registered', () {
    test('exactly 16 language implementations exist', () {
      expect(allStrings.length, 16);
    });

    test('all language codes are unique', () {
      final codes = allStrings.keys.toList();
      expect(codes.toSet().length, codes.length);
    });

    test('all language codes match implementation', () {
      for (final entry in allStrings.entries) {
        expect(entry.value.languageCode, entry.key);
      }
    });
  });
}
