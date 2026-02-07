import '../voice_strings.dart';

/// Spanish voice strings implementation (Español)
class VoiceStringsEs extends VoiceStrings {
  const VoiceStringsEs();

  @override
  String get languageCode => 'es';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'minuto' : 'minutos';
    return 'Su número de ticket es $ticketNumber. '
        'Está en la posición $position. '
        'Tiempo de espera estimado: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return '¡Atención! ¡Su número $ticketNumber ha sido llamado! '
        'Por favor, diríjase a $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'minuto' : 'minutos';
    return 'Tiempo de espera estimado: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Está en la posición $position en la cola.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Número $ticketNumber, por favor diríjase a $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'paciente espera' : 'pacientes esperan';
    final minText = avgWaitMinutes == 1 ? 'minuto' : 'minutos';
    return '$waitingCount $patientText. '
        'Tiempo de espera promedio: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'estado',
        'mi estado',
        'cuál es mi estado',
        'estado del ticket',
      ];

  @override
  List<String> get waitTimeCommands => [
        'tiempo de espera',
        'cuánto tiempo',
        'cuándo mi turno',
        'cuánto falta',
      ];

  @override
  List<String> get positionCommands => [
        'posición',
        'mi posición',
        'dónde estoy',
        'qué cola',
      ];

  @override
  List<String> get cancelCommands => [
        'cancelar',
        'anular',
        'eliminar ticket',
        'no quiero esperar',
      ];

  @override
  List<String> get helpCommands => [
        'ayuda',
        'qué puedo decir',
        'comandos',
        'opciones',
      ];

  @override
  List<String> get nextPatientCommands => [
        'siguiente paciente',
        'siguiente',
        'llamar',
        'llamar al siguiente',
      ];

  @override
  List<String> get patientDoneCommands => [
        'paciente terminado',
        'terminado',
        'finalizar',
        'hecho',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Mantén pulsado para hablar';

  @override
  String get listening => 'Escuchando...';

  @override
  String get processing => 'Procesando...';

  @override
  String get speakNow => 'Habla ahora';

  @override
  String get voiceEnabled => 'Función de voz activada';

  @override
  String get voiceDisabled => 'Función de voz desactivada';

  @override
  String get noMicrophonePermission =>
      'Se requiere permiso de micrófono. Por favor, permítalo en la configuración.';

  @override
  String get speechRecognitionUnavailable =>
      'Reconocimiento de voz no disponible en este dispositivo.';

  @override
  String get couldNotUnderstand => 'No entendí. Por favor, inténtelo de nuevo.';

  @override
  String get commandNotRecognized =>
      'Comando no reconocido. Diga "ayuda" para ver las opciones.';

  @override
  String get ticketCancelled => 'Su ticket ha sido cancelado.';

  @override
  String get confirmCancel => '¿Está seguro de que desea cancelar su ticket?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Puede decir: estado, tiempo de espera, posición, cancelar o ayuda.';

  @override
  String get staffHelpMessage =>
      'Puede decir: siguiente paciente, paciente terminado o resumen.';
}
