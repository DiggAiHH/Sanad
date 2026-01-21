export { API_BASE_URL, ENDPOINTS, APP_CONFIG } from './config';
export { 
  formatDate, 
  formatTime, 
  formatDateTime, 
  generateQRCodeData, 
  parseQRCodeData 
} from './utils';
export { default as ErrorBoundary } from './ErrorBoundary';

// Privacy & Data Protection
export { default as PRIVACY_CONFIG, DATA_CATEGORIES } from './privacy-config';
export { 
  secureLog,
  sanitizeLogData,
  generateAnonymousSessionId,
  containsPersonalData,
  createAuditLog,
  clearAllSessionData,
  validateApiResponse,
  generatePrivacyCompliantQRData,
  anonymizePatientId,
  checkSecurityStatus,
  shouldDeleteData,
  GDPRRights
} from './privacy-utils';

// Enhanced Features
export {
  translations,
  calculateWaitingTime,
  NotificationManager,
  AppointmentScheduler,
  FeedbackSystem,
  DocumentManager,
  EmergencyContactManager,
  HealthTipsProvider
} from './enhanced-features';
