import '../voice_strings.dart';

/// Portuguese voice strings implementation (Português)
class VoiceStringsPt extends VoiceStrings {
  const VoiceStringsPt();

  @override
  String get languageCode => 'pt';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'minuto' : 'minutos';
    return 'O seu número de senha é $ticketNumber. '
        'Está na posição $position. '
        'Tempo de espera estimado: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Atenção! O seu número $ticketNumber foi chamado! '
        'Por favor, dirija-se a $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'minuto' : 'minutos';
    return 'Tempo de espera estimado: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Está na posição $position na fila.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Número $ticketNumber, por favor dirija-se a $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'paciente à espera' : 'pacientes à espera';
    final minText = avgWaitMinutes == 1 ? 'minuto' : 'minutos';
    return '$waitingCount $patientText. '
        'Tempo de espera médio: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'estado',
        'meu estado',
        'qual é o meu estado',
        'estado da senha',
      ];

  @override
  List<String> get waitTimeCommands => [
        'tempo de espera',
        'quanto tempo',
        'quando a minha vez',
        'quanto falta',
      ];

  @override
  List<String> get positionCommands => [
        'posição',
        'minha posição',
        'onde estou',
        'qual fila',
      ];

  @override
  List<String> get cancelCommands => [
        'cancelar',
        'anular',
        'apagar senha',
        'não quero esperar',
      ];

  @override
  List<String> get helpCommands => [
        'ajuda',
        'o que posso dizer',
        'comandos',
        'opções',
      ];

  @override
  List<String> get nextPatientCommands => [
        'próximo paciente',
        'próximo',
        'chamar',
        'chamar o próximo',
      ];

  @override
  List<String> get patientDoneCommands => [
        'paciente terminado',
        'terminado',
        'finalizar',
        'feito',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Mantenha pressionado para falar';

  @override
  String get listening => 'A ouvir...';

  @override
  String get processing => 'A processar...';

  @override
  String get speakNow => 'Fale agora';

  @override
  String get voiceEnabled => 'Função de voz ativada';

  @override
  String get voiceDisabled => 'Função de voz desativada';

  @override
  String get noMicrophonePermission =>
      'Permissão de microfone necessária. Por favor, permita nas definições.';

  @override
  String get speechRecognitionUnavailable =>
      'Reconhecimento de voz não disponível neste dispositivo.';

  @override
  String get couldNotUnderstand => 'Não entendi. Por favor, tente novamente.';

  @override
  String get commandNotRecognized =>
      'Comando não reconhecido. Diga "ajuda" para opções.';

  @override
  String get ticketCancelled => 'A sua senha foi cancelada.';

  @override
  String get confirmCancel => 'Tem a certeza de que deseja cancelar a senha?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Pode dizer: estado, tempo de espera, posição, cancelar ou ajuda.';

  @override
  String get staffHelpMessage =>
      'Pode dizer: próximo paciente, paciente terminado ou resumo.';
}
