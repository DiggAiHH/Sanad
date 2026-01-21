// Privacy & Data Protection Configuration
// 100% GDPR/BDSG Compliant Settings

export const PRIVACY_CONFIG = {
  // Data Minimization
  dataMinimization: {
    enabled: true,
    collectOnlyNecessary: true,
    noTracking: true,
    noAnalytics: true,
  },

  // Storage Settings
  storage: {
    useLocalStorage: false,  // Never store personal data locally
    useSessionStorage: false, // Never store personal data in session
    useCookies: false,        // No cookies for tracking
    clearOnLogout: true,
    clearOnBrowserClose: true,
  },

  // Security Headers
  security: {
    httpsOnly: true,
    tlsVersion: '1.3',
    hsts: true,
    nosniff: true,
    xframeOptions: 'DENY',
    xssProtection: true,
  },

  // Data Retention
  retention: {
    qrCodeData: '0',          // Delete immediately after use
    sessionData: 'session',   // Keep only during session
    medicalRecords: '10y',    // 10 years (legal requirement)
    auditLogs: '10y',         // 10 years (legal requirement)
  },

  // Patient Rights
  patientRights: {
    rightToAccess: true,       // Art. 15 GDPR
    rightToRectification: true, // Art. 16 GDPR
    rightToErasure: true,      // Art. 17 GDPR (with exceptions)
    rightToDataPortability: true, // Art. 20 GDPR
    rightToObject: true,       // Art. 21 GDPR
  },

  // Logging (for audit trail)
  logging: {
    enabled: true,
    logPersonalData: false,    // Never log personal data
    logTechnicalOnly: true,
    auditTrail: true,
    immutable: true,
  },

  // Encryption
  encryption: {
    dataAtRest: 'AES-256',
    dataInTransit: 'TLS-1.3',
    endToEnd: true,
  },

  // Legal Basis
  legalBasis: {
    contract: 'Art. 6 Abs. 1 lit. b DSGVO',     // Contract fulfillment
    healthcare: 'Art. 9 Abs. 2 lit. h DSGVO',   // Healthcare provision
    legalObligation: 'Art. 6 Abs. 1 lit. c DSGVO', // Legal compliance
  },
};

// Data Categories and Purpose
export const DATA_CATEGORIES = {
  identity: {
    fields: ['patientId', 'name', 'dateOfBirth'],
    purpose: 'Patient identification',
    legalBasis: 'Art. 6 Abs. 1 lit. b DSGVO',
    retention: '10 years',
  },
  appointment: {
    fields: ['appointmentId', 'date', 'time', 'doctorId'],
    purpose: 'Appointment management',
    legalBasis: 'Art. 6 Abs. 1 lit. b DSGVO',
    retention: '10 years',
  },
  health: {
    fields: ['diagnosis', 'treatment', 'medication'],
    purpose: 'Medical care provision',
    legalBasis: 'Art. 9 Abs. 2 lit. h DSGVO',
    retention: '10 years',
    specialCategory: true, // Sensitive data
  },
  checkin: {
    fields: ['timestamp', 'status'],
    purpose: 'Reception management',
    legalBasis: 'Art. 6 Abs. 1 lit. b DSGVO',
    retention: 'Immediate deletion after process',
  },
};

// No-Log Policy for Sensitive Data
export const noLogPatterns = [
  /patient.*name/i,
  /diagnosis/i,
  /treatment/i,
  /health.*data/i,
  /medical.*record/i,
  /password/i,
  /token/i,
  /ssn/i,
  /insurance.*number/i,
];

// Sanitize function for logging
export const sanitizeForLog = (data) => {
  const sanitized = { ...data };
  
  // Remove all personal data
  delete sanitized.patientName;
  delete sanitized.name;
  delete sanitized.dateOfBirth;
  delete sanitized.address;
  delete sanitized.phone;
  delete sanitized.email;
  delete sanitized.healthData;
  delete sanitized.diagnosis;
  delete sanitized.treatment;
  
  // Keep only technical data
  return {
    timestamp: sanitized.timestamp,
    action: sanitized.action,
    status: sanitized.status,
    sessionId: sanitized.sessionId?.substring(0, 8) + '...', // Truncate
  };
};

// API Request Headers for Privacy
export const PRIVACY_HEADERS = {
  'X-Data-Minimization': 'enabled',
  'X-No-Tracking': 'true',
  'X-Purpose-Limitation': 'healthcare',
};

// Data Breach Response
export const DATA_BREACH_PROTOCOL = {
  immediate: {
    isolateSystem: true,
    stopBreach: true,
    documentEverything: true,
    notifyDPO: true, // Data Protection Officer
    timeframe: '1 hour',
  },
  notification: {
    notifyAuthority: true,
    notifyPatients: 'if high risk',
    timeframe: '72 hours',
  },
  documentation: {
    what: 'Description of breach',
    when: 'Exact timestamp',
    impact: 'Number of affected patients',
    measures: 'Actions taken',
  },
};

export default PRIVACY_CONFIG;
