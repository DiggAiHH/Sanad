import '../voice_strings.dart';

/// French voice strings implementation (Français)
class VoiceStringsFr extends VoiceStrings {
  const VoiceStringsFr();

  @override
  String get languageCode => 'fr';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'minute' : 'minutes';
    return 'Votre numéro de ticket est $ticketNumber. '
        'Vous êtes en position $position. '
        'Temps d\'attente estimé: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Attention! Votre numéro $ticketNumber a été appelé! '
        'Veuillez vous rendre à $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'minute' : 'minutes';
    return 'Temps d\'attente estimé: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Vous êtes en position $position dans la file d\'attente.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Numéro $ticketNumber, veuillez vous rendre à $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'patient attend' : 'patients attendent';
    final minText = avgWaitMinutes == 1 ? 'minute' : 'minutes';
    return '$waitingCount $patientText. '
        'Temps d\'attente moyen: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'statut',
        'mon statut',
        'quel est mon statut',
        'état du ticket',
      ];

  @override
  List<String> get waitTimeCommands => [
        'temps d\'attente',
        'combien de temps',
        'quand mon tour',
        'combien attendre',
      ];

  @override
  List<String> get positionCommands => [
        'position',
        'ma position',
        'où suis-je',
        'quelle file',
      ];

  @override
  List<String> get cancelCommands => [
        'annuler',
        'annulation',
        'supprimer ticket',
        'je ne veux plus attendre',
      ];

  @override
  List<String> get helpCommands => [
        'aide',
        'que puis-je dire',
        'commandes',
        'options',
      ];

  @override
  List<String> get nextPatientCommands => [
        'patient suivant',
        'suivant',
        'appeler',
        'appeler le suivant',
      ];

  @override
  List<String> get patientDoneCommands => [
        'patient terminé',
        'terminé',
        'finaliser',
        'fait',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Maintenez pour parler';

  @override
  String get listening => 'Écoute en cours...';

  @override
  String get processing => 'Traitement...';

  @override
  String get speakNow => 'Parlez maintenant';

  @override
  String get voiceEnabled => 'Fonction vocale activée';

  @override
  String get voiceDisabled => 'Fonction vocale désactivée';

  @override
  String get noMicrophonePermission =>
      'Autorisation du microphone requise. Veuillez l\'autoriser dans les paramètres.';

  @override
  String get speechRecognitionUnavailable =>
      'Reconnaissance vocale non disponible sur cet appareil.';

  @override
  String get couldNotUnderstand => 'Je n\'ai pas compris. Veuillez réessayer.';

  @override
  String get commandNotRecognized =>
      'Commande non reconnue. Dites "aide" pour les options.';

  @override
  String get ticketCancelled => 'Votre ticket a été annulé.';

  @override
  String get confirmCancel => 'Êtes-vous sûr de vouloir annuler votre ticket?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Vous pouvez dire: statut, temps d\'attente, position, annuler ou aide.';

  @override
  String get staffHelpMessage =>
      'Vous pouvez dire: patient suivant, patient terminé ou aperçu.';
}
