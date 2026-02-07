// Enhanced Features Module
// Additional functionalities for improved user experience

/**
 * Multi-Language Support (i18n)
 * Supports German (de) and Arabic (ar) for diverse patient base
 */
export const translations = {
  de: {
    // Common
    welcome: 'Willkommen',
    logout: 'Abmelden',
    save: 'Speichern',
    cancel: 'Abbrechen',
    confirm: 'Bestätigen',
    delete: 'Löschen',
    edit: 'Bearbeiten',
    
    // Reception
    checkIn: 'Einchecken',
    scanQR: 'QR-Code scannen',
    scanNFC: 'NFC-Karte scannen',
    checkInSuccess: 'Erfolgreich eingecheckt',
    waitingTime: 'Wartezeit',
    estimatedWait: 'Geschätzte Wartezeit',
    
    // Patient Portal
    myAppointments: 'Meine Termine',
    bookAppointment: 'Termin buchen',
    medicalRecords: 'Krankenakte',
    prescriptions: 'Rezepte',
    labResults: 'Laborergebnisse',
    uploadDocuments: 'Dokumente hochladen',
    emergencyContact: 'Notfallkontakt',
    
    // Doctor Portal
    patientQueue: 'Patientenwarteschlange',
    currentPatient: 'Aktueller Patient',
    callNext: 'Nächsten aufrufen',
    treatmentNotes: 'Behandlungsnotizen',
    prescribeMedication: 'Medikament verschreiben',
    
    // Appointments
    reschedule: 'Umbuchen',
    cancelAppointment: 'Termin absagen',
    appointmentDetails: 'Termindetails',
    
    // Notifications
    newAppointment: 'Neuer Termin gebucht',
    appointmentReminder: 'Terminerinnerung',
    labResultsReady: 'Laborergebnisse verfügbar',
  },
  ar: {
    // Common
    welcome: 'مرحبا',
    logout: 'تسجيل خروج',
    save: 'حفظ',
    cancel: 'إلغاء',
    confirm: 'تأكيد',
    delete: 'حذف',
    edit: 'تعديل',
    
    // Reception
    checkIn: 'تسجيل الوصول',
    scanQR: 'مسح رمز الاستجابة السريعة',
    scanNFC: 'مسح بطاقة NFC',
    checkInSuccess: 'تم تسجيل الوصول بنجاح',
    waitingTime: 'وقت الانتظار',
    estimatedWait: 'وقت الانتظار المتوقع',
    
    // Patient Portal
    myAppointments: 'مواعيدي',
    bookAppointment: 'حجز موعد',
    medicalRecords: 'السجلات الطبية',
    prescriptions: 'الوصفات الطبية',
    labResults: 'نتائج المختبر',
    uploadDocuments: 'تحميل المستندات',
    emergencyContact: 'جهة اتصال الطوارئ',
    
    // Doctor Portal
    patientQueue: 'قائمة انتظار المرضى',
    currentPatient: 'المريض الحالي',
    callNext: 'استدعاء التالي',
    treatmentNotes: 'ملاحظات العلاج',
    prescribeMedication: 'وصف الدواء',
    
    // Appointments
    reschedule: 'إعادة جدولة',
    cancelAppointment: 'إلغاء الموعد',
    appointmentDetails: 'تفاصيل الموعد',
    
    // Notifications
    newAppointment: 'تم حجز موعد جديد',
    appointmentReminder: 'تذكير بالموعد',
    labResultsReady: 'نتائج المختبر جاهزة',
  },
  en: {
    // Common
    welcome: 'Welcome',
    logout: 'Logout',
    save: 'Save',
    cancel: 'Cancel',
    confirm: 'Confirm',
    delete: 'Delete',
    edit: 'Edit',
    
    // Reception
    checkIn: 'Check In',
    scanQR: 'Scan QR Code',
    scanNFC: 'Scan NFC Card',
    checkInSuccess: 'Successfully Checked In',
    waitingTime: 'Waiting Time',
    estimatedWait: 'Estimated Wait Time',
    
    // Patient Portal
    myAppointments: 'My Appointments',
    bookAppointment: 'Book Appointment',
    medicalRecords: 'Medical Records',
    prescriptions: 'Prescriptions',
    labResults: 'Lab Results',
    uploadDocuments: 'Upload Documents',
    emergencyContact: 'Emergency Contact',
    
    // Doctor Portal
    patientQueue: 'Patient Queue',
    currentPatient: 'Current Patient',
    callNext: 'Call Next',
    treatmentNotes: 'Treatment Notes',
    prescribeMedication: 'Prescribe Medication',
    
    // Appointments
    reschedule: 'Reschedule',
    cancelAppointment: 'Cancel Appointment',
    appointmentDetails: 'Appointment Details',
    
    // Notifications
    newAppointment: 'New Appointment Booked',
    appointmentReminder: 'Appointment Reminder',
    labResultsReady: 'Lab Results Available',
  },
};

/**
 * Waiting Time Calculator
 * Estimates patient waiting time based on queue position and average consultation time
 */
export const calculateWaitingTime = (queuePosition, avgConsultationMinutes = 15) => {
  const waitMinutes = queuePosition * avgConsultationMinutes;
  const hours = Math.floor(waitMinutes / 60);
  const minutes = waitMinutes % 60;
  
  return {
    minutes: waitMinutes,
    formatted: hours > 0 
      ? `${hours}h ${minutes}min` 
      : `${minutes} min`,
    estimatedTime: new Date(Date.now() + waitMinutes * 60000).toLocaleTimeString('de-DE', {
      hour: '2-digit',
      minute: '2-digit'
    }),
  };
};

/**
 * Notification System
 * Manages patient notifications (SMS, Email, Push)
 */
export class NotificationManager {
  constructor() {
    this.notifications = [];
  }
  
  /**
   * Send appointment reminder
   * @param {Object} appointment - Appointment details
   * @param {number} hoursBefore - Hours before appointment to remind
   */
  scheduleReminder(appointment, hoursBefore = 24) {
    const reminderTime = new Date(appointment.dateTime);
    reminderTime.setHours(reminderTime.getHours() - hoursBefore);
    
    return {
      type: 'reminder',
      message: `Terminerinnerung: Ihr Termin ist am ${appointment.date} um ${appointment.time}`,
      scheduledFor: reminderTime,
      appointment: appointment,
    };
  }
  
  /**
   * Notify when lab results are ready
   */
  labResultsReady(patientId) {
    return {
      type: 'lab_results',
      message: 'Ihre Laborergebnisse sind jetzt verfügbar',
      patientId: patientId,
      timestamp: new Date(),
    };
  }
  
  /**
   * Notify about queue position update
   */
  queuePositionUpdate(currentPosition, estimatedWait) {
    return {
      type: 'queue_update',
      message: `Sie sind jetzt Position ${currentPosition} in der Warteschlange`,
      estimatedWait: estimatedWait,
      timestamp: new Date(),
    };
  }
}

/**
 * Appointment Scheduling
 * Handles appointment booking and rescheduling
 */
export class AppointmentScheduler {
  /**
   * Get available time slots for a doctor
   * @param {string} doctorId - Doctor ID
   * @param {Date} date - Date to check availability
   * @returns {Array} Available time slots
   */
  getAvailableSlots(doctorId, date) {
    // Mock available slots (in production, fetch from backend)
    const workingHours = {
      start: 8,
      end: 18,
      slotDuration: 30, // minutes
    };
    
    const slots = [];
    for (let hour = workingHours.start; hour < workingHours.end; hour++) {
      for (let minute = 0; minute < 60; minute += workingHours.slotDuration) {
        slots.push({
          time: `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`,
          available: Math.random() > 0.3, // Mock availability
          doctorId: doctorId,
          date: date,
        });
      }
    }
    
    return slots.filter(slot => slot.available);
  }
  
  /**
   * Book an appointment
   * @param {Object} appointmentData - Appointment details
   * @returns {Object} Confirmation
   */
  bookAppointment(appointmentData) {
    return {
      success: true,
      appointmentId: 'A' + Date.now(),
      confirmation: {
        ...appointmentData,
        bookingTime: new Date(),
        qrCode: this.generateQRCode(appointmentData),
      },
    };
  }
  
  /**
   * Reschedule an existing appointment
   * @param {string} appointmentId - Existing appointment ID
   * @param {Object} newDateTime - New date and time
   */
  rescheduleAppointment(appointmentId, newDateTime) {
    return {
      success: true,
      appointmentId: appointmentId,
      oldDateTime: { /* previous data */ },
      newDateTime: newDateTime,
      rescheduledAt: new Date(),
    };
  }
  
  generateQRCode(appointmentData) {
    return JSON.stringify({
      patientId: appointmentData.patientId,
      appointmentId: appointmentData.appointmentId,
      timestamp: Date.now(),
    });
  }
}

/**
 * Patient Feedback System
 * Collects and manages patient satisfaction feedback
 */
export class FeedbackSystem {
  /**
   * Submit feedback after appointment
   * @param {Object} feedback - Feedback data
   */
  submitFeedback(feedback) {
    return {
      feedbackId: 'F' + Date.now(),
      ...feedback,
      submittedAt: new Date(),
      status: 'received',
    };
  }
  
  /**
   * Get feedback form template
   */
  getFeedbackForm() {
    return {
      questions: [
        {
          id: 'q1',
          type: 'rating',
          question: 'Wie zufrieden waren Sie mit dem Service?',
          scale: 5,
        },
        {
          id: 'q2',
          type: 'rating',
          question: 'Wie war die Wartezeit?',
          scale: 5,
        },
        {
          id: 'q3',
          type: 'text',
          question: 'Weitere Kommentare oder Vorschläge?',
          maxLength: 500,
        },
      ],
    };
  }
}

/**
 * Document Upload Manager
 * Handles medical document uploads (GDPR compliant)
 */
export class DocumentManager {
  /**
   * Validate document before upload
   * @param {File} file - File to validate
   * @returns {Object} Validation result
   */
  validateDocument(file) {
    const maxSize = 10 * 1024 * 1024; // 10MB
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
    
    return {
      valid: file.size <= maxSize && allowedTypes.includes(file.type),
      error: file.size > maxSize 
        ? 'Datei zu groß (max 10MB)' 
        : !allowedTypes.includes(file.type)
        ? 'Dateiformat nicht unterstützt'
        : null,
      file: file,
    };
  }
  
  /**
   * Upload document (mock - real implementation on backend)
   * @param {File} file - Document file
   * @param {Object} metadata - Document metadata
   */
  async uploadDocument(file, metadata) {
    // In production: encrypt and upload to secure backend
    return {
      documentId: 'DOC' + Date.now(),
      fileName: file.name,
      fileSize: file.size,
      uploadedAt: new Date(),
      encrypted: true,
      ...metadata,
    };
  }
}

/**
 * Emergency Contact Management
 * Manage patient emergency contacts
 */
export class EmergencyContactManager {
  /**
   * Add/Update emergency contact
   * @param {Object} contact - Contact details
   */
  updateEmergencyContact(contact) {
    return {
      contactId: 'EC' + Date.now(),
      ...contact,
      updatedAt: new Date(),
    };
  }
  
  /**
   * Get emergency contact template
   */
  getContactTemplate() {
    return {
      name: '',
      relationship: '', // spouse, parent, sibling, friend
      phoneNumber: '',
      alternativePhone: '',
      address: '',
    };
  }
}

/**
 * Health Tips Provider
 * Provides health tips and educational content
 */
export class HealthTipsProvider {
  /**
   * Get daily health tip
   * @param {string} language - Language code (de, ar, en)
   */
  getDailyTip(language = 'de') {
    const tips = {
      de: [
        'Trinken Sie mindestens 2 Liter Wasser pro Tag',
        '30 Minuten Bewegung täglich hält Sie fit',
        'Achten Sie auf ausreichend Schlaf (7-9 Stunden)',
        'Regelmäßige Vorsorgeuntersuchungen sind wichtig',
        'Gesunde Ernährung stärkt Ihr Immunsystem',
      ],
      ar: [
        'اشرب ما لا يقل عن 2 لتر من الماء يوميًا',
        '30 دقيقة من الحركة يوميًا تبقيك بصحة جيدة',
        'احرص على النوم الكافي (7-9 ساعات)',
        'الفحوصات الدورية المنتظمة مهمة',
        'التغذية الصحية تقوي جهازك المناعي',
      ],
      en: [
        'Drink at least 2 liters of water per day',
        '30 minutes of exercise daily keeps you fit',
        'Ensure adequate sleep (7-9 hours)',
        'Regular check-ups are important',
        'Healthy eating strengthens your immune system',
      ],
    };
    
    const languageTips = tips[language] || tips.en;
    return languageTips[Math.floor(Math.random() * languageTips.length)];
  }
}

export default {
  translations,
  calculateWaitingTime,
  NotificationManager,
  AppointmentScheduler,
  FeedbackSystem,
  DocumentManager,
  EmergencyContactManager,
  HealthTipsProvider,
};
