/// Sanad Voice Package
/// 
/// Provides Text-to-Speech (TTS) and Speech-to-Text (STT) capabilities
/// with multi-language support for all Sanad apps.
/// 
/// Supported Languages:
/// - Phase 1 (P0): German, English, Turkish, Arabic
/// - Phase 2 (P1): Russian, Polish, French, Spanish
/// - Phase 3 (P2): Italian, Portuguese, Ukrainian, Farsi, Urdu
/// - Phase 4 (P3): Vietnamese, Romanian, Greek
library sanad_voice;

// TTS
export 'src/tts/tts_service.dart';

// STT
export 'src/stt/stt_service.dart';

// Commands
export 'src/commands/command_parser.dart';

// Announcements
export 'src/announcements/announcement_builder.dart';

// Localization
export 'src/localization/voice_strings.dart';
export 'src/localization/supported_languages.dart';
export 'src/localization/strings/voice_strings_de.dart';
export 'src/localization/strings/voice_strings_en.dart';
export 'src/localization/strings/voice_strings_tr.dart';
export 'src/localization/strings/voice_strings_ar.dart';
export 'src/localization/strings/voice_strings_ru.dart';
export 'src/localization/strings/voice_strings_pl.dart';
export 'src/localization/strings/voice_strings_fr.dart';
export 'src/localization/strings/voice_strings_es.dart';
export 'src/localization/strings/voice_strings_it.dart';
export 'src/localization/strings/voice_strings_pt.dart';
export 'src/localization/strings/voice_strings_uk.dart';
export 'src/localization/strings/voice_strings_fa.dart';
export 'src/localization/strings/voice_strings_ur.dart';
export 'src/localization/strings/voice_strings_vi.dart';
export 'src/localization/strings/voice_strings_ro.dart';
export 'src/localization/strings/voice_strings_el.dart';

// Providers
export 'src/providers/voice_provider.dart';

// Widgets
export 'src/widgets/voice_buttons.dart';
export 'src/widgets/voice_settings.dart';
