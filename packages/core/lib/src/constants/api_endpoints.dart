/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

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
}
