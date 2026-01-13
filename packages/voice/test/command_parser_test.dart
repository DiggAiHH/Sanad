import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_voice/src/commands/command_parser.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_de.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_en.dart';

void main() {
  group('CommandParser', () {
    group('German commands', () {
      late CommandParser parser;

      setUp(() {
        parser = CommandParser(const VoiceStringsDe());
      });

      test('parses exact status command', () {
        final result = parser.parse('wie ist mein status');

        expect(result.type, VoiceCommandType.status);
        expect(result.confidence, 1.0);
      });

      test('parses status command with variations', () {
        final variations = [
          'status',
          'mein status',
          'ticket status',
        ];

        for (final text in variations) {
          final result = parser.parse(text);
          expect(result.type, VoiceCommandType.status,
              reason: 'Failed for: $text');
        }
      });

      test('parses wait time command', () {
        final result = parser.parse('wie lange muss ich noch warten');

        expect(result.type, VoiceCommandType.waitTime);
      });

      test('parses position command', () {
        final result = parser.parse('welche position habe ich');

        expect(result.type, VoiceCommandType.position);
      });

      test('parses cancel command', () {
        final result = parser.parse('ticket stornieren');

        expect(result.type, VoiceCommandType.cancel);
      });

      test('parses help command', () {
        final result = parser.parse('hilfe');

        expect(result.type, VoiceCommandType.help);
      });

      test('parses next patient command', () {
        final result = parser.parse('nächster patient');

        expect(result.type, VoiceCommandType.nextPatient);
      });

      test('parses patient done command', () {
        final result = parser.parse('patient fertig');

        expect(result.type, VoiceCommandType.patientDone);
      });

      test('returns unknown for gibberish', () {
        final result = parser.parse('asdfghjkl');

        expect(result.type, VoiceCommandType.unknown);
        expect(result.confidence, 0.0);
      });

      test('fuzzy matches with typos', () {
        final result = parser.parse('wie ist mien statsu'); // typos

        expect(result.type, VoiceCommandType.status);
        expect(result.confidence, greaterThan(0.6));
        expect(result.confidence, lessThan(1.0));
      });

      test('isConfirmation returns true for ja', () {
        expect(parser.isConfirmation('ja'), isTrue);
        expect(parser.isConfirmation('Ja, bitte'), isTrue);
      });

      test('isDenial returns true for nein', () {
        expect(parser.isDenial('nein'), isTrue);
        expect(parser.isDenial('Nein danke'), isTrue);
      });
    });

    group('English commands', () {
      late CommandParser parser;

      setUp(() {
        parser = CommandParser(const VoiceStringsEn());
      });

      test('parses exact status command', () {
        final result = parser.parse("what's my status");

        expect(result.type, VoiceCommandType.status);
      });

      test('parses wait time command', () {
        final result = parser.parse('how long do I have to wait');

        expect(result.type, VoiceCommandType.waitTime);
      });

      test('parses help command', () {
        final result = parser.parse('help');

        expect(result.type, VoiceCommandType.help);
      });

      test('isConfirmation returns true for yes', () {
        expect(parser.isConfirmation('yes'), isTrue);
      });

      test('isDenial returns true for no', () {
        expect(parser.isDenial('no'), isTrue);
      });
    });

    group('case insensitivity', () {
      late CommandParser parser;

      setUp(() {
        parser = CommandParser(const VoiceStringsDe());
      });

      test('parses uppercase commands', () {
        final result = parser.parse('HILFE');

        expect(result.type, VoiceCommandType.help);
      });

      test('parses mixed case commands', () {
        final result = parser.parse('HiLfE');

        expect(result.type, VoiceCommandType.help);
      });
    });

    group('punctuation handling', () {
      late CommandParser parser;

      setUp(() {
        parser = CommandParser(const VoiceStringsDe());
      });

      test('ignores trailing punctuation', () {
        final result = parser.parse('hilfe!');

        expect(result.type, VoiceCommandType.help);
      });

      test('ignores question marks', () {
        final result = parser.parse('wie ist mein status?');

        expect(result.type, VoiceCommandType.status);
      });
    });

    group('min match score', () {
      test('rejects low confidence matches with high threshold', () {
        final parser = CommandParser(
          const VoiceStringsDe(),
          minMatchScore: 0.9,
        );

        final result = parser.parse('wie ist mien statsu'); // typos

        // With high threshold, typos should be rejected
        expect(result.type, VoiceCommandType.unknown);
      });

      test('accepts low confidence matches with low threshold', () {
        final parser = CommandParser(
          const VoiceStringsDe(),
          minMatchScore: 0.5,
        );

        final result = parser.parse('stats'); // very short

        expect(result.type, VoiceCommandType.status);
      });
    });
  });
}
