/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL for the API - configured via environment
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String qrLogin = '/auth/qr-login';
  static const String nfcLogin = '/auth/nfc-login';

  // Users
  static const String users = '/users';
  static const String userProfile = '/users/me';

  // Practices
  static const String practices = '/practices';
  static String practice(String id) => '/practices/$id';

  // Queue
  static String queue(String practiceId) => '/practices/$practiceId/queue';
  static String queueTickets(String practiceId) =>
      '/practices/$practiceId/queue/tickets';
  static String queueTicket(String practiceId, String ticketId) =>
      '/practices/$practiceId/queue/tickets/$ticketId';
  static String callNext(String practiceId) =>
      '/practices/$practiceId/queue/call-next';
  static String queueCategories(String practiceId) =>
      '/practices/$practiceId/queue/categories';

  // Staff
  static String staff(String practiceId) => '/practices/$practiceId/staff';
  static String staffMember(String practiceId, String staffId) =>
      '/practices/$practiceId/staff/$staffId';

  // Patients
  static String patients(String practiceId) => '/practices/$practiceId/patients';
  static String patient(String practiceId, String patientId) =>
      '/practices/$practiceId/patients/$patientId';

  // Tasks
  static const String tasks = '/tasks';
  static String task(String id) => '/tasks/$id';

  // Chat
  static const String chatRooms = '/chat/rooms';
  static String chatRoom(String id) => '/chat/rooms/$id';
  static String chatMessages(String roomId) => '/chat/rooms/$roomId/messages';
  static String chatMessage(String roomId, String messageId) =>
      '/chat/rooms/$roomId/messages/$messageId';
  static const String chatUnread = '/chat/unread';

  // Content
  static const String educationContent = '/content/education';
  static String educationContentItem(String id) => '/content/education/$id';
  static const String videoContent = '/content/videos';
  static String videoContentItem(String id) => '/content/videos/$id';

  // Document Requests (Rezept, AU, Überweisung)
  static const String documentRequests = '/document-requests';
  static String documentRequest(String id) => '/document-requests/$id';
  static const String myDocumentRequests = '/document-requests/my';

  // Medications
  static const String medications = '/medications';
  static const String myMedications = '/medications/my';
  static const String myMedicationPlan = '/medications/my/plan';
  static const String myMedicationScheduleToday = '/medications/my/schedule/today';

  // Consultations (Video, Voice, Chat mit Arzt)
  static const String consultations = '/consultations';
  static String consultation(String id) => '/consultations/$id';
  static const String myConsultations = '/consultations/my-consultations';
  static String consultationMessages(String id) => '/consultations/$id/messages';
  static String consultationCallRoom(String id) => '/consultations/$id/room';
  static String consultationJoin(String id) => '/consultations/$id/join';
  static String consultationEnd(String id) => '/consultations/$id/end';
  static String consultationCancel(String id) => '/consultations/my-consultations/$id/cancel';
  static String consultationMessagesRead(String id) => '/consultations/$id/messages/read';
  
  // WebRTC Signaling
  static String webrtcOffer(String consultationId) => '/consultations/$consultationId/signal/offer';
  static String webrtcAnswer(String consultationId) => '/consultations/$consultationId/signal/answer';
  static String webrtcIce(String consultationId) => '/consultations/$consultationId/signal/ice';
  static String webrtcPoll(String consultationId) => '/consultations/$consultationId/signal/poll';
  static String webrtcClear(String consultationId) => '/consultations/$consultationId/signal';
}
