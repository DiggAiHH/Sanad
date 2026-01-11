export const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

export const ENDPOINTS = {
  PATIENTS: '/api/patients',
  APPOINTMENTS: '/api/appointments',
  DOCTORS: '/api/doctors',
  CHECK_IN: '/api/checkin',
  ANALYTICS: '/api/analytics',
};

export const APP_CONFIG = {
  NFC_ENABLED: true,
  QR_CODE_ENABLED: true,
  AUTO_CHECK_IN: true,
};
