import 'supported_languages.dart';

// Import all language implementations
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

/// Abstract class for voice localization strings
abstract class VoiceStrings {
  const VoiceStrings();

  /// Get the language code
  String get languageCode;

  // ============== TICKET STATUS ==============

  /// Template for ticket status announcement
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  });

  /// Template for ticket called announcement
  String ticketCalled({
    required String ticketNumber,
    required String room,
  });

  /// Wait time only
  String waitTime({required int minutes});

  /// Position only
  String position({required int position});

  // ============== QUEUE ANNOUNCEMENTS ==============

  /// Patient call announcement (for speakers)
  String patientCall({
    required String ticketNumber,
    required String room,
  });

  /// Queue status
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  });

  // ============== COMMANDS ==============

  /// "Status" command variations
  List<String> get statusCommands;

  /// "Wait time" command variations
  List<String> get waitTimeCommands;

  /// "Position" command variations
  List<String> get positionCommands;

  /// "Cancel" command variations
  List<String> get cancelCommands;

  /// "Help" command variations
  List<String> get helpCommands;

  /// "Next patient" command (staff)
  List<String> get nextPatientCommands;

  /// "Patient done" command (staff)
  List<String> get patientDoneCommands;

  // ============== UI STRINGS ==============

  /// "Hold to speak" hint
  String get holdToSpeak;

  /// "Listening..." indicator
  String get listening;

  /// "Processing..." indicator
  String get processing;

  /// "Speak now" prompt
  String get speakNow;

  /// "Voice enabled" confirmation
  String get voiceEnabled;

  /// "Voice disabled" confirmation
  String get voiceDisabled;

  /// Error: No microphone permission
  String get noMicrophonePermission;

  /// Error: Speech recognition unavailable
  String get speechRecognitionUnavailable;

  /// Error: Could not understand
  String get couldNotUnderstand;

  // ============== OPTIONAL UI/HELP STRINGS (DEFAULTS) ==============

  /// Error: Command not recognized
  String get commandNotRecognized => 'Command not recognized. Say "help" for options.';

  /// Confirmation: Ticket cancelled
  String get ticketCancelled => 'Your ticket has been cancelled.';

  /// Confirmation prompt for cancelling the ticket
  String get confirmCancel => 'Are you sure you want to cancel your ticket?';

  /// Confirmation: Yes
  String get yes => 'Yes';

  /// Confirmation: No
  String get no => 'No';

  /// Help text for patients
  String get helpMessage =>
      'You can say: status, wait time, position, cancel, or help.';

  /// Help text for staff
  String get staffHelpMessage =>
      'You can say: next patient, patient done, or overview.';

  // ============== OPTIONAL SETTINGS STRINGS (DEFAULTS) ==============

  /// Voice settings title
  String get voiceSettingsTitle => 'Voice Features';

  /// Enable voice label
  String get enableVoice => 'Enable voice features';

  /// Language selection label
  String get selectLanguage => 'Select language';

  /// Voice selection label
  String get selectVoice => 'Select voice';

  /// Speech rate label
  String get speechRate => 'Speech rate';

  /// Volume label
  String get volume => 'Volume';

  /// Test announcement button
  String get testAnnouncement => 'Play test announcement';

  // ============== OPTIONAL ACCESSIBILITY (DEFAULTS) ==============

  /// Ticket status semantic label
  String ticketStatusSemantic({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'Ticket $ticketNumber, position $position, wait time $waitMinutes minutes';
  }

  /// Get VoiceStrings for a specific language
  static VoiceStrings forLanguage(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.german:
        return const VoiceStringsDe();
      case SupportedLanguage.english:
        return const VoiceStringsEn();
      case SupportedLanguage.turkish:
        return const VoiceStringsTr();
      case SupportedLanguage.arabic:
        return const VoiceStringsAr();
      case SupportedLanguage.russian:
        return const VoiceStringsRu();
      case SupportedLanguage.polish:
        return const VoiceStringsPl();
      case SupportedLanguage.french:
        return const VoiceStringsFr();
      case SupportedLanguage.spanish:
        return const VoiceStringsEs();
      case SupportedLanguage.italian:
        return const VoiceStringsIt();
      case SupportedLanguage.portuguese:
        return const VoiceStringsPt();
      case SupportedLanguage.ukrainian:
        return const VoiceStringsUk();
      case SupportedLanguage.farsi:
        return const VoiceStringsFa();
      case SupportedLanguage.urdu:
        return const VoiceStringsUr();
      case SupportedLanguage.vietnamese:
        return const VoiceStringsVi();
      case SupportedLanguage.romanian:
        return const VoiceStringsRo();
      case SupportedLanguage.greek:
        return const VoiceStringsEl();
    }
  }

  /// Get VoiceStrings by language code
  static VoiceStrings? forLanguageCode(String code) {
    final lang = SupportedLanguage.fromCode(code);
    if (lang != null) {
      return forLanguage(lang);
    }
    return null;
  }
}
