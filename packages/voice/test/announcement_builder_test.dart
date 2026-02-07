import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_voice/src/announcements/announcement_builder.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_de.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_en.dart';
import 'package:sanad_voice/src/localization/strings/voice_strings_ar.dart';

void main() {
  group('AnnouncementBuilder', () {
    group('German announcements', () {
      late AnnouncementBuilder builder;

      setUp(() {
        builder = AnnouncementBuilder(const VoiceStringsDe());
      });

      test('builds ticket status announcement', () {
        final announcement = builder.ticketStatus(
          ticketNumber: 'A-047',
          position: 3,
          waitMinutes: 10,
        );

        expect(announcement.type, AnnouncementType.ticketStatus);
        expect(announcement.languageCode, 'de');
        expect(announcement.text, contains('A-047'));
        expect(announcement.text, contains('3'));
      });

      test('builds ticket called announcement', () {
        final announcement = builder.ticketCalled(
          ticketNumber: 'B-123',
          room: 'Zimmer 5',
        );

        expect(announcement.type, AnnouncementType.ticketCalled);
        expect(announcement.priority, 1);
        expect(announcement.repeat, isTrue);
        expect(announcement.repeatCount, 2);
        expect(announcement.text, contains('B-123'));
        expect(announcement.text, contains('Zimmer 5'));
      });

      test('builds patient call announcement', () {
        final announcement = builder.patientCall(
          ticketNumber: 'C-456',
          room: 'Raum 3',
        );

        expect(announcement.type, AnnouncementType.patientCall);
        expect(announcement.priority, 1);
        expect(announcement.text, contains('C-456'));
      });

      test('builds queue status announcement', () {
        final announcement = builder.queueStatus(
          waitingCount: 5,
          avgWaitMinutes: 15,
        );

        expect(announcement.type, AnnouncementType.queueStatus);
        expect(announcement.text, contains('5'));
      });

      test('builds wait time announcement', () {
        final announcement = builder.waitTime(minutes: 20);

        expect(announcement.type, AnnouncementType.waitTime);
        expect(announcement.text, contains('20'));
      });

      test('builds position announcement', () {
        final announcement = builder.position(position: 7);

        expect(announcement.type, AnnouncementType.position);
        expect(announcement.text, contains('7'));
      });

      test('builds custom announcement', () {
        final announcement = builder.custom('Bitte Maske tragen', priority: 2);

        expect(announcement.type, AnnouncementType.custom);
        expect(announcement.priority, 2);
        expect(announcement.text, 'Bitte Maske tragen');
      });

      test('includes SSML by default', () {
        final announcement = builder.ticketCalled(
          ticketNumber: 'A-001',
          room: 'Zimmer 1',
        );

        expect(announcement.ssml, isNotNull);
        expect(announcement.ssml, contains('<speak>'));
        expect(announcement.ssml, isNot(contains('https://')));
      });
    });

    group('English announcements', () {
      late AnnouncementBuilder builder;

      setUp(() {
        builder = AnnouncementBuilder(const VoiceStringsEn());
      });

      test('uses English language code', () {
        final announcement = builder.ticketStatus(
          ticketNumber: 'A-047',
          position: 3,
          waitMinutes: 10,
        );

        expect(announcement.languageCode, 'en');
      });

      test('generates English text', () {
        final announcement = builder.ticketCalled(
          ticketNumber: 'D-789',
          room: 'Room 4',
        );

        expect(announcement.text, contains('D-789'));
      });
    });

    group('Arabic announcements', () {
      late AnnouncementBuilder builder;

      setUp(() {
        builder = AnnouncementBuilder(const VoiceStringsAr());
      });

      test('uses Arabic language code', () {
        final announcement = builder.ticketStatus(
          ticketNumber: 'A-047',
          position: 3,
          waitMinutes: 10,
        );

        expect(announcement.languageCode, 'ar');
      });
    });

    group('SSML disabled', () {
      late AnnouncementBuilder builder;

      setUp(() {
        builder = AnnouncementBuilder(const VoiceStringsDe(), useSSML: false);
      });

      test('does not include SSML', () {
        final announcement = builder.ticketCalled(
          ticketNumber: 'A-001',
          room: 'Zimmer 1',
        );

        expect(announcement.ssml, isNull);
      });
    });
  });

  group('AnnouncementBuilderFactory', () {
    test('creates builder for language code', () {
      final builder = AnnouncementBuilderFactory.forLanguage('de');
      final announcement = builder.waitTime(minutes: 5);

      expect(announcement.languageCode, 'de');
    });

    test('creates builder for system language', () {
      final builder = AnnouncementBuilderFactory.forSystemLanguage();

      expect(builder.languageCode, 'de'); // Default is German
    });
  });

  group('Announcement', () {
    test('toString truncates long text', () {
      final announcement = Announcement(
        type: AnnouncementType.custom,
        text: 'A' * 100,
        languageCode: 'de',
      );

      final str = announcement.toString();
      expect(str, contains('...'));
      expect(str.length, lessThan(100));
    });

    test('toString shows full short text', () {
      final announcement = Announcement(
        type: AnnouncementType.custom,
        text: 'Short text',
        languageCode: 'de',
      );

      final str = announcement.toString();
      expect(str, contains('Short text'));
      expect(str, isNot(contains('...')));
    });
  });
}
