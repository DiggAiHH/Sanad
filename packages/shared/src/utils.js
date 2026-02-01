export const formatDate = (date) => {
  if (!date) return '';
  const d = new Date(date);
  return d.toLocaleDateString('de-DE', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
};

export const formatTime = (date) => {
  if (!date) return '';
  const d = new Date(date);
  return d.toLocaleTimeString('de-DE', {
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const formatDateTime = (date) => {
  return `${formatDate(date)} ${formatTime(date)}`;
};

export const generateQRCodeData = (patientId, appointmentId) => {
  return JSON.stringify({
    patientId,
    appointmentId,
    timestamp: Date.now(),
  });
};

export const parseQRCodeData = (qrData) => {
  try {
    return JSON.parse(qrData);
  } catch (e) {
    // Never log the actual QR data as it contains personal information (GDPR)
    console.error('Invalid QR code data format');
    return null;
  }
};
