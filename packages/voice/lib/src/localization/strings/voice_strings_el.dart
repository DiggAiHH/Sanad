import '../voice_strings.dart';

/// Greek voice strings implementation (Ελληνικά)
class VoiceStringsEl extends VoiceStrings {
  const VoiceStringsEl();

  @override
  String get languageCode => 'el';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'λεπτό' : 'λεπτά';
    return 'Ο αριθμός εισιτηρίου σας είναι $ticketNumber. '
        'Είστε στη θέση $position. '
        'Εκτιμώμενος χρόνος αναμονής: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Προσοχή! Ο αριθμός σας $ticketNumber καλέστηκε! '
        'Παρακαλώ προσέλθετε στο $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'λεπτό' : 'λεπτά';
    return 'Εκτιμώμενος χρόνος αναμονής: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Είστε στη θέση $position στην ουρά.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Αριθμός $ticketNumber, παρακαλώ στο $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'ασθενής περιμένει' : 'ασθενείς περιμένουν';
    final minText = avgWaitMinutes == 1 ? 'λεπτό' : 'λεπτά';
    return '$waitingCount $patientText. '
        'Μέσος χρόνος αναμονής: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'κατάσταση',
        'η κατάστασή μου',
        'ποια είναι η κατάστασή μου',
        'κατάσταση εισιτηρίου',
      ];

  @override
  List<String> get waitTimeCommands => [
        'χρόνος αναμονής',
        'πόση ώρα',
        'πότε η σειρά μου',
        'πόσο ακόμα',
      ];

  @override
  List<String> get positionCommands => [
        'θέση',
        'η θέση μου',
        'πού είμαι',
        'ποια ουρά',
      ];

  @override
  List<String> get cancelCommands => [
        'ακύρωση',
        'ακύρωσε',
        'διαγραφή εισιτηρίου',
        'δεν θέλω να περιμένω',
      ];

  @override
  List<String> get helpCommands => [
        'βοήθεια',
        'τι μπορώ να πω',
        'εντολές',
        'επιλογές',
      ];

  @override
  List<String> get nextPatientCommands => [
        'επόμενος ασθενής',
        'επόμενος',
        'καλέστε',
        'καλέστε τον επόμενο',
      ];

  @override
  List<String> get patientDoneCommands => [
        'ασθενής έτοιμος',
        'έτοιμο',
        'ολοκλήρωση',
        'τέλος',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Κρατήστε πατημένο για να μιλήσετε';

  @override
  String get listening => 'Ακούω...';

  @override
  String get processing => 'Επεξεργασία...';

  @override
  String get speakNow => 'Μιλήστε τώρα';

  @override
  String get voiceEnabled => 'Η φωνητική λειτουργία ενεργοποιήθηκε';

  @override
  String get voiceDisabled => 'Η φωνητική λειτουργία απενεργοποιήθηκε';

  @override
  String get noMicrophonePermission =>
      'Απαιτείται άδεια μικροφώνου. Παρακαλώ επιτρέψτε στις ρυθμίσεις.';

  @override
  String get speechRecognitionUnavailable =>
      'Η αναγνώριση ομιλίας δεν είναι διαθέσιμη σε αυτή τη συσκευή.';

  @override
  String get couldNotUnderstand => 'Δεν κατάλαβα. Παρακαλώ δοκιμάστε ξανά.';

  @override
  String get commandNotRecognized =>
      'Μη αναγνωρισμένη εντολή. Πείτε "βοήθεια" για επιλογές.';

  @override
  String get ticketCancelled => 'Το εισιτήριό σας ακυρώθηκε.';

  @override
  String get confirmCancel => 'Είστε σίγουροι ότι θέλετε να ακυρώσετε το εισιτήριο;';

  @override
  String get yes => 'Ναι';

  @override
  String get no => 'Όχι';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Μπορείτε να πείτε: κατάσταση, χρόνος αναμονής, θέση, ακύρωση ή βοήθεια.';

  @override
  String get staffHelpMessage =>
      'Μπορείτε να πείτε: επόμενος ασθενής, ασθενής έτοιμος ή επισκόπηση.';
}
