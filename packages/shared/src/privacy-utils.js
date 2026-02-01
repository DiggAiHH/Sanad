// Privacy & Security Utility Functions
// GDPR/BDSG Compliant Helper Functions

/**
 * Secure logging function that never logs personal data
 * @param {string} message - Log message
 * @param {object} data - Technical data only (no personal info)
 */
export const secureLog = (message, data = {}) => {
  // Only log in development or for specific technical issues
  if (process.env.NODE_ENV === 'development') {
    console.log(`[SECURE] ${message}`, sanitizeLogData(data));
  }
  
  // In production, send only to secure audit system (if implemented)
  if (process.env.NODE_ENV === 'production' && process.env.REACT_APP_AUDIT_ENDPOINT) {
    sendToAuditLog(message, data);
  }
};

/**
 * Sanitize data before logging - remove all personal information
 * @param {object} data - Data to sanitize
 * @returns {object} - Sanitized data with personal info removed
 */
export const sanitizeLogData = (data) => {
  if (!data || typeof data !== 'object') return {};
  
  const sensitive = [
    'name', 'patientName', 'firstName', 'lastName',
    'dateOfBirth', 'dob', 'birthDate',
    'address', 'street', 'city', 'zipCode',
    'phone', 'mobile', 'telephone',
    'email', 'mail',
    'ssn', 'socialSecurity', 'insuranceNumber',
    'diagnosis', 'treatment', 'medication',
    'healthData', 'medicalRecord', 'symptoms',
    'password', 'token', 'secret', 'key'
  ];
  
  const sanitized = { ...data };
  
  // Remove sensitive fields
  sensitive.forEach(field => {
    if (sanitized[field]) {
      delete sanitized[field];
    }
  });
  
  // Truncate IDs to prevent re-identification
  if (sanitized.patientId) {
    sanitized.patientId = sanitized.patientId.substring(0, 4) + '...';
  }
  
  return sanitized;
};

/**
 * Generate anonymous session ID for audit trail
 * @returns {string} - Anonymous session ID
 */
export const generateAnonymousSessionId = () => {
  return 'session_' + Date.now() + '_' + Math.random().toString(36).substring(7);
};

/**
 * Check if data contains personal information
 * @param {object} data - Data to check
 * @returns {boolean} - True if contains personal data
 */
export const containsPersonalData = (data) => {
  const personalDataPattern = /(name|email|phone|address|birth|health|medical|patient|diagnosis)/i;
  const dataString = JSON.stringify(data);
  return personalDataPattern.test(dataString);
};

/**
 * Encrypt sensitive data before transmission (frontend mock - real encryption on backend)
 * @param {string} data - Data to encrypt
 * @returns {string} - Base64 encoded data (mock - use real encryption on backend)
 */
export const encryptData = (data) => {
  // Frontend encryption is NOT secure - this is just a placeholder
  // Real encryption must happen on the backend with proper key management
  console.warn('Frontend encryption is not secure. Use backend encryption.');
  return btoa(data); // Base64 encoding (NOT encryption)
};

/**
 * Create audit log entry (to be sent to secure backend)
 * @param {string} action - Action performed
 * @param {object} metadata - Technical metadata only
 */
export const createAuditLog = (action, metadata = {}) => {
  return {
    timestamp: new Date().toISOString(),
    action: action,
    sessionId: metadata.sessionId || generateAnonymousSessionId(),
    appName: metadata.appName || 'unknown',
    status: metadata.status || 'unknown',
    // Never include personal data in audit logs
  };
};

/**
 * Clear all session data on logout
 */
export const clearAllSessionData = () => {
  // Clear session storage
  sessionStorage.clear();
  
  // Clear any application state
  if (window.applicationState) {
    window.applicationState = null;
  }
  
  secureLog('Session data cleared');
};

/**
 * Validate API response doesn't expose sensitive data
 * @param {object} response - API response
 * @returns {boolean} - True if response is safe
 */
export const validateApiResponse = (response) => {
  // Check for sensitive data in response
  if (containsPersonalData(response)) {
    console.warn('API response may contain sensitive data');
  }
  
  // Validate HTTPS
  if (window.location.protocol !== 'https:' && process.env.NODE_ENV === 'production') {
    console.error('SECURITY WARNING: Not using HTTPS in production');
    return false;
  }
  
  return true;
};

/**
 * Generate privacy-compliant QR code data
 * @param {string} patientId - Patient ID (only ID, no personal info)
 * @param {string} appointmentId - Appointment ID
 * @returns {object} - Minimal QR code data
 */
export const generatePrivacyCompliantQRData = (patientId, appointmentId) => {
  // Only include minimum necessary data
  return {
    pid: patientId,      // Patient ID only (pseudonymous)
    aid: appointmentId,  // Appointment ID only
    ts: Date.now(),      // Timestamp for validation
    // NO personal data (name, DOB, etc.)
  };
};

/**
 * Anonymize patient ID for display
 * @param {string} patientId - Full patient ID
 * @returns {string} - Anonymized ID
 */
export const anonymizePatientId = (patientId) => {
  if (!patientId || patientId.length < 4) return '***';
  return patientId.substring(0, 2) + '***' + patientId.substring(patientId.length - 2);
};

/**
 * Check if browser session is secure
 * @returns {object} - Security status
 */
export const checkSecurityStatus = () => {
  return {
    https: window.location.protocol === 'https:',
    secureContext: window.isSecureContext,
    localStorage: typeof localStorage !== 'undefined',
    sessionStorage: typeof sessionStorage !== 'undefined',
    cookiesEnabled: navigator.cookieEnabled,
  };
};

/**
 * Data retention checker
 * @param {Date} createdDate - Date when data was created
 * @param {number} retentionYears - Retention period in years
 * @returns {boolean} - True if data should be deleted
 */
export const shouldDeleteData = (createdDate, retentionYears = 10) => {
  const now = new Date();
  const created = new Date(createdDate);
  const yearsDiff = (now - created) / (1000 * 60 * 60 * 24 * 365);
  return yearsDiff > retentionYears;
};

/**
 * Send to audit log (backend endpoint)
 * @param {string} message - Log message
 * @param {object} data - Sanitized data
 */
const sendToAuditLog = async (message, data) => {
  try {
    if (!process.env.REACT_APP_AUDIT_ENDPOINT) return;
    
    await fetch(process.env.REACT_APP_AUDIT_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        timestamp: new Date().toISOString(),
        message: message,
        data: sanitizeLogData(data),
      }),
    });
  } catch (error) {
    // Silently fail - don't expose audit endpoint errors
    console.error('Audit log failed');
  }
};

/**
 * GDPR Rights Helper
 * 
 * NOTE: These functions are PLACEHOLDER STUBS that require backend implementation.
 * They should throw errors until properly implemented to avoid false GDPR compliance claims.
 */
export const GDPRRights = {
  /**
   * Request data export (Art. 15 GDPR)
   * @throws {Error} Not implemented - requires backend API
   */
  requestDataExport: async (patientId) => {
    secureLog('Data export requested');
    throw new Error('GDPR data export not implemented - requires backend API integration');
    // TODO: Implement backend API call
    // return await fetch(`/api/gdpr/export/${patientId}`);
  },
  
  /**
   * Request data deletion (Art. 17 GDPR)
   * @throws {Error} Not implemented - requires backend API
   */
  requestDataDeletion: async (patientId, reason) => {
    secureLog('Data deletion requested', { reason });
    throw new Error('GDPR data deletion not implemented - requires backend API integration');
    // TODO: Implement backend API call
    // return await fetch(`/api/gdpr/delete/${patientId}`, { method: 'DELETE' });
  },
  
  /**
   * Request data rectification (Art. 16 GDPR)
   * @throws {Error} Not implemented - requires backend API
   */
  requestDataRectification: async (patientId, corrections) {
    secureLog('Data rectification requested');
    throw new Error('GDPR data rectification not implemented - requires backend API integration');
    // TODO: Implement backend API call
    // return await fetch(`/api/gdpr/rectify/${patientId}`, { method: 'PATCH', body: corrections });
  },
  
  /**
   * Request data portability (Art. 20 GDPR)
   * @throws {Error} Not implemented - requires backend API
   */
  requestDataPortability: async (patientId, format = 'json') {
    secureLog('Data portability requested', { format });
    throw new Error('GDPR data portability not implemented - requires backend API integration');
    // TODO: Implement backend API call
    // return await fetch(`/api/gdpr/export/${patientId}?format=${format}`);
  },
};

export default {
  secureLog,
  sanitizeLogData,
  generateAnonymousSessionId,
  containsPersonalData,
  encryptData,
  createAuditLog,
  clearAllSessionData,
  validateApiResponse,
  generatePrivacyCompliantQRData,
  anonymizePatientId,
  checkSecurityStatus,
  shouldDeleteData,
  GDPRRights,
};
