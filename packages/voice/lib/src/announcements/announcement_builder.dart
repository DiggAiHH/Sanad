import '../localization/voice_strings.dart';
import '../localization/supported_languages.dart';

/// Announcement types
enum AnnouncementType {
  ticketStatus,
  ticketCalled,
  patientCall,
  queueStatus,
  waitTime,
  position,
  custom,
}

/// Structured announcement data
class Announcement {
  final AnnouncementType type;
  final String text;
  final String languageCode;
  final String? ssml;
  final int? priority; // 1 = highest
  final bool repeat;
  final int repeatCount;
  final Duration repeatDelay;

  const Announcement({
    required this.type,
    required this.text,
    required this.languageCode,
    this.ssml,
    this.priority,
    this.repeat = false,
    this.repeatCount = 1,
    this.repeatDelay = const Duration(seconds: 2),
  });

  @override
  String toString() =>
      'Announcement(type: $type, lang: $languageCode, text: "${text.length > 50 ? '${text.substring(0, 50)}...' : text}")';
}

/// Builds announcements with localization and SSML support
/// 
/// Usage:
/// ```dart
/// final builder = AnnouncementBuilder(VoiceStringsDe());
/// final announcement = builder.ticketCalled(
///   ticketNumber: 'A-047',
///   room: 'Zimmer 3',
/// );
/// ```
class AnnouncementBuilder {
  final VoiceStrings _strings;
  final bool _useSSML;

  AnnouncementBuilder(
    this._strings, {
    bool useSSML = true,
  }) : _useSSML = useSSML;

  /// Get current language code
  String get languageCode => _strings.languageCode;

  /// Build ticket status announcement
  Announcement ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final text = _strings.ticketStatus(
      ticketNumber: ticketNumber,
      position: position,
      waitMinutes: waitMinutes,
    );

    return Announcement(
      type: AnnouncementType.ticketStatus,
      text: text,
      languageCode: _strings.languageCode,
      ssml: _useSSML ? _buildStatusSSML(ticketNumber, position, waitMinutes) : null,
    );
  }

  /// Build ticket called announcement (urgent)
  Announcement ticketCalled({
    required String ticketNumber,
    required String room,
    bool repeat = true,
  }) {
    final text = _strings.ticketCalled(
      ticketNumber: ticketNumber,
      room: room,
    );

    return Announcement(
      type: AnnouncementType.ticketCalled,
      text: text,
      languageCode: _strings.languageCode,
      ssml: _useSSML ? _buildCalledSSML(ticketNumber, room) : null,
      priority: 1,
      repeat: repeat,
      repeatCount: 2,
      repeatDelay: const Duration(seconds: 3),
    );
  }

  /// Build patient call announcement (for speakers)
  Announcement patientCall({
    required String ticketNumber,
    required String room,
  }) {
    final text = _strings.patientCall(
      ticketNumber: ticketNumber,
      room: room,
    );

    return Announcement(
      type: AnnouncementType.patientCall,
      text: text,
      languageCode: _strings.languageCode,
      ssml: _useSSML ? _buildPatientCallSSML(ticketNumber, room) : null,
      priority: 1,
    );
  }

  /// Build queue status announcement
  Announcement queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final text = _strings.queueStatus(
      waitingCount: waitingCount,
      avgWaitMinutes: avgWaitMinutes,
    );

    return Announcement(
      type: AnnouncementType.queueStatus,
      text: text,
      languageCode: _strings.languageCode,
    );
  }

  /// Build wait time only announcement
  Announcement waitTime({required int minutes}) {
    final text = _strings.waitTime(minutes: minutes);

    return Announcement(
      type: AnnouncementType.waitTime,
      text: text,
      languageCode: _strings.languageCode,
    );
  }

  /// Build position only announcement
  Announcement position({required int position}) {
    final text = _strings.position(position: position);

    return Announcement(
      type: AnnouncementType.position,
      text: text,
      languageCode: _strings.languageCode,
    );
  }

  /// Build custom announcement
  Announcement custom(String text, {int? priority}) {
    return Announcement(
      type: AnnouncementType.custom,
      text: text,
      languageCode: _strings.languageCode,
      priority: priority,
    );
  }

  // ============== SSML BUILDERS ==============

  String _buildStatusSSML(String ticketNumber, int position, int waitMinutes) {
    final parts = _parseTicketNumber(ticketNumber);
    
    return '''
<speak>
  <prosody rate="95%">
    ${_strings.languageCode.startsWith('de') ? 'Ihre Ticketnummer' : 'Your ticket number'}
    <break time="200ms"/>
    <say-as interpret-as="characters">${parts.prefix}</say-as>
    <break time="100ms"/>
    <say-as interpret-as="digits">${parts.number}</say-as>
    <break time="300ms"/>
    ${_strings.position(position: position)}
    <break time="300ms"/>
    ${_strings.waitTime(minutes: waitMinutes)}
  </prosody>
</speak>
''';
  }

  String _buildCalledSSML(String ticketNumber, String room) {
    final parts = _parseTicketNumber(ticketNumber);
    
    return '''
<speak>
  <break time="200ms"/>
  <prosody rate="90%" pitch="+5%">
    <emphasis level="strong">
      ${_strings.languageCode.startsWith('de') ? 'Achtung!' : 'Attention!'}
    </emphasis>
    <break time="200ms"/>
    ${_strings.languageCode.startsWith('de') ? 'Ihre Nummer' : 'Your number'}
    <break time="150ms"/>
    <say-as interpret-as="characters">${parts.prefix}</say-as>
    <break time="100ms"/>
    <say-as interpret-as="digits">${parts.number}</say-as>
    <break time="200ms"/>
    ${_strings.languageCode.startsWith('de') ? 'wurde aufgerufen!' : 'has been called!'}
    <break time="400ms"/>
    ${_strings.languageCode.startsWith('de') ? 'Bitte begeben Sie sich zu' : 'Please proceed to'}
    <break time="150ms"/>
    $room
  </prosody>
</speak>
''';
  }

  String _buildPatientCallSSML(String ticketNumber, String room) {
    final parts = _parseTicketNumber(ticketNumber);
    
    return '''
<speak>
  <break time="200ms"/>
  <prosody rate="85%" pitch="+3%">
    ${_strings.languageCode.startsWith('de') ? 'Nummer' : 'Number'}
    <break time="150ms"/>
    <say-as interpret-as="characters">${parts.prefix}</say-as>
    <break time="100ms"/>
    <say-as interpret-as="digits">${parts.number}</say-as>
    <break time="400ms"/>
    ${_strings.languageCode.startsWith('de') ? 'bitte zu' : 'please to'}
    <break time="150ms"/>
    $room
  </prosody>
</speak>
''';
  }

  /// Parse ticket number into prefix and number parts
  _TicketParts _parseTicketNumber(String ticketNumber) {
    final match = RegExp(r'^([A-Z]+)-?(\d+)$').firstMatch(ticketNumber.toUpperCase());
    if (match != null) {
      return _TicketParts(
        prefix: match.group(1) ?? '',
        number: match.group(2) ?? '',
      );
    }
    return _TicketParts(prefix: '', number: ticketNumber);
  }
}

class _TicketParts {
  final String prefix;
  final String number;

  _TicketParts({required this.prefix, required this.number});
}

/// Factory for creating AnnouncementBuilder with correct language
class AnnouncementBuilderFactory {
  /// Create builder for a specific language
  static AnnouncementBuilder forLanguage(String languageCode) {
    final strings = SupportedLanguages.getStrings(languageCode);
    return AnnouncementBuilder(strings);
  }

  /// Create builder for system default language
  static AnnouncementBuilder forSystemLanguage() {
    return forLanguage(SupportedLanguages.defaultLanguage);
  }
}
