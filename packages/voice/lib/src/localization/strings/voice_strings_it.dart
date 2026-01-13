import '../voice_strings.dart';

/// Italian voice strings implementation (Italiano)
class VoiceStringsIt extends VoiceStrings {
  const VoiceStringsIt();

  @override
  String get languageCode => 'it';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'minuto' : 'minuti';
    return 'Il tuo numero di biglietto è $ticketNumber. '
        'Sei in posizione $position. '
        'Tempo di attesa stimato: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Attenzione! Il tuo numero $ticketNumber è stato chiamato! '
        'Per favore, recati a $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'minuto' : 'minuti';
    return 'Tempo di attesa stimato: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Sei in posizione $position nella coda.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Numero $ticketNumber, per favore recati a $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'paziente in attesa' : 'pazienti in attesa';
    final minText = avgWaitMinutes == 1 ? 'minuto' : 'minuti';
    return '$waitingCount $patientText. '
        'Tempo di attesa medio: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'stato',
        'il mio stato',
        'qual è il mio stato',
        'stato del biglietto',
      ];

  @override
  List<String> get waitTimeCommands => [
        'tempo di attesa',
        'quanto tempo',
        'quando il mio turno',
        'quanto manca',
      ];

  @override
  List<String> get positionCommands => [
        'posizione',
        'la mia posizione',
        'dove sono',
        'quale coda',
      ];

  @override
  List<String> get cancelCommands => [
        'annulla',
        'cancella',
        'elimina biglietto',
        'non voglio aspettare',
      ];

  @override
  List<String> get helpCommands => [
        'aiuto',
        'cosa posso dire',
        'comandi',
        'opzioni',
      ];

  @override
  List<String> get nextPatientCommands => [
        'prossimo paziente',
        'prossimo',
        'chiama',
        'chiama il prossimo',
      ];

  @override
  List<String> get patientDoneCommands => [
        'paziente finito',
        'finito',
        'completare',
        'fatto',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Tieni premuto per parlare';

  @override
  String get listening => 'Ascolto...';

  @override
  String get processing => 'Elaborazione...';

  @override
  String get speakNow => 'Parla ora';

  @override
  String get voiceEnabled => 'Funzione vocale attivata';

  @override
  String get voiceDisabled => 'Funzione vocale disattivata';

  @override
  String get noMicrophonePermission =>
      'Autorizzazione microfono richiesta. Si prega di consentire nelle impostazioni.';

  @override
  String get speechRecognitionUnavailable =>
      'Riconoscimento vocale non disponibile su questo dispositivo.';

  @override
  String get couldNotUnderstand => 'Non ho capito. Per favore, riprova.';

  @override
  String get commandNotRecognized =>
      'Comando non riconosciuto. Dì "aiuto" per le opzioni.';

  @override
  String get ticketCancelled => 'Il tuo biglietto è stato annullato.';

  @override
  String get confirmCancel => 'Sei sicuro di voler annullare il biglietto?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Puoi dire: stato, tempo di attesa, posizione, annulla o aiuto.';

  @override
  String get staffHelpMessage =>
      'Puoi dire: prossimo paziente, paziente finito o panoramica.';
}
