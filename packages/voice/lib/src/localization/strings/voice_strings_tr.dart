import '../voice_strings.dart';

/// Turkish voice strings implementation
class VoiceStringsTr extends VoiceStrings {
  const VoiceStringsTr();

  @override
  String get languageCode => 'tr';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'Bilet numaranız $ticketNumber. '
        'Sırada $position. sıradasınız. '
        'Tahmini bekleme süresi: $waitMinutes dakika.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Dikkat! $ticketNumber numaranız çağrıldı! '
        'Lütfen $room\'a geçiniz.';
  }

  @override
  String waitTime({required int minutes}) {
    return 'Tahmini bekleme süresi: $minutes dakika.';
  }

  @override
  String position({required int position}) {
    return 'Sırada $position. sıradasınız.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return '$ticketNumber numaralı hasta, lütfen $room\'a geçiniz.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    return '$waitingCount hasta bekliyor. '
        'Ortalama bekleme süresi: $avgWaitMinutes dakika.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'durum',
        'benim durumum',
        'durumum ne',
        'bilet durumu',
      ];

  @override
  List<String> get waitTimeCommands => [
        'bekleme süresi',
        'ne kadar',
        'daha ne kadar',
        'sıram ne zaman',
      ];

  @override
  List<String> get positionCommands => [
        'pozisyon',
        'sıram',
        'kaçıncıyım',
        'neredeyim',
      ];

  @override
  List<String> get cancelCommands => [
        'iptal',
        'iptal et',
        'bileti sil',
        'beklemekten vazgeç',
      ];

  @override
  List<String> get helpCommands => [
        'yardım',
        'ne söyleyebilirim',
        'komutlar',
        'seçenekler',
      ];

  @override
  List<String> get nextPatientCommands => [
        'sonraki hasta',
        'sonraki',
        'çağır',
        'sonrakini çağır',
      ];

  @override
  List<String> get patientDoneCommands => [
        'hasta bitti',
        'bitti',
        'tamamla',
        'bitir',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Konuşmak için basılı tutun';

  @override
  String get listening => 'Dinleniyor...';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get speakNow => 'Şimdi konuşun';

  @override
  String get voiceEnabled => 'Ses özellikleri etkinleştirildi';

  @override
  String get voiceDisabled => 'Ses özellikleri devre dışı bırakıldı';

  @override
  String get noMicrophonePermission =>
      'Mikrofon izni gerekli. Lütfen ayarlardan izin verin.';

  @override
  String get speechRecognitionUnavailable =>
      'Bu cihazda konuşma tanıma mevcut değil.';

  @override
  String get couldNotUnderstand => 'Anlayamadım. Lütfen tekrar deneyin.';

  // ============== SETTINGS ==============

  @override
  String get voiceSettingsTitle => 'Ses Özellikleri';

  @override
  String get enableVoice => 'Ses özelliklerini etkinleştir';

  @override
  String get selectLanguage => 'Dil seçin';

  @override
  String get selectVoice => 'Ses seçin';

  @override
  String get speechRate => 'Konuşma hızı';

  @override
  String get volume => 'Ses seviyesi';

  @override
  String get testAnnouncement => 'Test anonsu çal';

  // ============== ACCESSIBILITY ==============

  @override
  String ticketStatusSemantic({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'Bilet $ticketNumber, pozisyon $position, '
        'bekleme süresi $waitMinutes dakika';
  }
}
