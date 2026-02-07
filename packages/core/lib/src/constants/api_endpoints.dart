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

  // Appointments (Online-Terminbuchung)
  static const String appointments = '/appointments';
  static const String appointmentTypes = '/appointments/types';
  static const String appointmentAvailability = '/appointments/availability';
  static const String appointmentNextAvailable = '/appointments/next-available';
  static const String appointmentBook = '/appointments/book';
  static const String myAppointments = '/appointments/my';
  static String appointment(String id) => '/appointments/$id';
  static String appointmentReschedule(String id) => '/appointments/$id/reschedule';
  static String appointmentReminderSettings(String id) =>
      '/appointments/$id/reminder-settings';
  
  // WebRTC Signaling
  static String webrtcOffer(String consultationId) => '/consultations/$consultationId/signal/offer';
  static String webrtcAnswer(String consultationId) => '/consultations/$consultationId/signal/answer';
  static String webrtcIce(String consultationId) => '/consultations/$consultationId/signal/ice';
  static String webrtcPoll(String consultationId) => '/consultations/$consultationId/signal/poll';
  static String webrtcClear(String consultationId) => '/consultations/$consultationId/signal';

  // Anamnesis
  static const String anamnesisTemplates = '/anamnesis/templates';
  static String anamnesisTemplate(String id) => '/anamnesis/templates/$id';
  static const String anamnesisSubmit = '/anamnesis/submit';
  static const String anamnesisMySubmissions = '/anamnesis/my-submissions';
  static String anamnesisSubmission(String id) => '/anamnesis/submission/$id';
  static String anamnesisForAppointment(String appointmentId) =>
      '/anamnesis/for-appointment/$appointmentId';

  // Symptom checker
  static const String symptomCatalog = '/symptom-checker/symptoms';
  static const String symptomRedFlags = '/symptom-checker/red-flags';
  static const String symptomCheck = '/symptom-checker/check';
  static const String symptomSaveSession = '/symptom-checker/save-session';

  // Lab results
  static const String myLabResults = '/lab-results/my';
  static String myLabResult(String id) => '/lab-results/my/$id';
  static const String myLabResultsPendingCount = '/lab-results/my/pending-count';
  static const String labResultsReferenceValues = '/lab-results/reference-values';
  static const String labResultsRelease = '/lab-results/release';
  static String labResultsMarkDiscussed(String id) =>
      '/lab-results/$id/mark-discussed';

  // Vaccinations
  static const String myVaccinations = '/vaccinations/my';
  static const String myVaccinationPass = '/vaccinations/my/pass';
  static const String myVaccinationRecommendations = '/vaccinations/my/recommendations';
  static const String myUpcomingVaccinations = '/vaccinations/my/upcoming';
  static String myVaccination(String id) => '/vaccinations/my/$id';
  static const String myVaccinationRecalls = '/vaccinations/recalls/my';
  static String acknowledgeVaccinationRecall(String recallId) =>
      '/vaccinations/recalls/$recallId/acknowledge';
  static String scheduleVaccinationRecall(String recallId) =>
      '/vaccinations/recalls/$recallId/schedule';
  static const String vaccinationExportWhoCard = '/vaccinations/my/export/who-card';
  static const String vaccinationExportEuDcc = '/vaccinations/my/export/eu-dcc';

  // Forms
  static const String forms = '/forms';
  static const String formCategories = '/forms/categories';
  static String form(String id) => '/forms/$id';
  static String formDownload(String id) => '/forms/$id/download';
  static String formSubmit(String id) => '/forms/$id/submit';

  // Workflows
  static const String workflows = '/workflows';
  static String workflow(String id) => '/workflows/$id';
  static String workflowStatus(String id) => '/workflows/$id/status';
  static String workflowTrigger(String id) => '/workflows/$id/trigger';
  static const String workflowTasks = '/workflows/tasks/';
  static String workflowCompleteTask(String id) => '/workflows/tasks/$id/complete';
  static const String workflowRunDue = '/workflows/scheduler/run-due';
}
