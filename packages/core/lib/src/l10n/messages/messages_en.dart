// =============================================================================
// ENGLISH (en_US)
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Submit',
  'button_cancel': 'Cancel',
  'button_save': 'Save',
  'button_delete': 'Delete',
  'button_edit': 'Edit',
  'button_back': 'Back',
  'button_next': 'Next',
  'button_close': 'Close',
  'button_confirm': 'Confirm',
  'button_retry': 'Retry',
  'button_refresh': 'Refresh',
  'button_login': 'Login',
  'button_logout': 'Logout',
  'button_register': 'Register',

  // --- Navigation ---
  'nav_home': 'Home',
  'nav_settings': 'Settings',
  'nav_profile': 'Profile',
  'nav_help': 'Help',

  // --- Status ---
  'status_loading': 'Loading...',
  'status_error': 'An error occurred',
  'status_success': 'Success',
  'status_empty': 'No data available',
  'status_offline': 'Offline',
  'status_online': 'Online',

  // --- Validation ---
  'validation_required': 'This field is required',
  'validation_email': 'Please enter a valid email address',
  'validation_min_length': 'Minimum {min} characters required',
  'validation_max_length': 'Maximum {max} characters allowed',
  'validation_phone': 'Please enter a valid phone number',

  // --- Auth ---
  'auth_email': 'Email Address',
  'auth_password': 'Password',
  'auth_forgot_password': 'Forgot password?',
  'auth_login_title': 'Login',
  'auth_register_title': 'Create Account',
  'auth_welcome': 'Welcome back!',

  // --- Queue/Ticket ---
  'ticket_number': 'Ticket Number',
  'ticket_status': 'Status',
  'ticket_status_waiting': 'Waiting',
  'ticket_status_called': 'Called',
  'ticket_status_in_progress': 'In Progress',
  'ticket_status_completed': 'Completed',
  'ticket_status_cancelled': 'Cancelled',
  'ticket_wait_time': 'Estimated Wait Time',
  'ticket_position': 'Position in Queue',
  'queue_title': 'Queue',
  'queue_empty': 'The queue is empty',

  // --- Appointments ---
  'appointment_title': 'Appointments',
  'appointment_book': 'Book Appointment',
  'appointment_cancel': 'Cancel Appointment',
  'appointment_reschedule': 'Reschedule',
  'appointment_confirmed': 'Appointment Confirmed',
  'appointment_date': 'Date',
  'appointment_time': 'Time',
  'appointment_doctor': 'Doctor',
  'appointment_reason': 'Reason for Visit',
  'appointment_no_upcoming': 'No upcoming appointments',

  // --- Documents ---
  'doc_request_title': 'Document Requests',
  'doc_prescription': 'Prescription',
  'doc_sick_note': 'Sick Note',
  'doc_referral': 'Referral',
  'doc_certificate': 'Certificate',
  'doc_status_pending': 'Pending',
  'doc_status_ready': 'Ready for Pickup',
  'doc_status_rejected': 'Rejected',

  // --- Consultation ---
  'consultation_title': 'Consultation',
  'consultation_video': 'Video Consultation',
  'consultation_phone': 'Phone Consultation',
  'consultation_chat': 'Chat',
  'consultation_callback': 'Request Callback',
  'consultation_start': 'Start Consultation',
  'consultation_end': 'End Consultation',
  'consultation_waiting': 'Waiting for doctor...',

  // --- Medical Data ---
  'med_lab_results': 'Lab Results',
  'med_findings': 'Findings',
  'med_medications': 'Medications',
  'med_vaccinations': 'Vaccinations',
  'med_history': 'Medical History',
  'med_allergies': 'Allergies',

  // --- Anamnesis ---
  'anamnesis_title': 'Medical History',
  'anamnesis_start': 'Start Questionnaire',
  'anamnesis_complete': 'Complete Questionnaire',
  'anamnesis_symptoms': 'Symptoms',
  'anamnesis_duration': 'How long have you had these symptoms?',
  'anamnesis_severity': 'How severe are your symptoms? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Practice Information',
  'practice_hours': 'Opening Hours',
  'practice_address': 'Address',
  'practice_phone': 'Phone',
  'practice_emergency': 'Emergency: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Privacy',
  'privacy_consent': 'I consent to the processing of my data',
  'privacy_data_export': 'Export my data',
  'privacy_data_delete': 'Delete my data',
  'privacy_consent_revoke': 'Revoke consent',

  // --- Errors ---
  'error_generic': 'An unexpected error occurred',
  'error_network': 'No internet connection',
  'error_auth': 'Authentication failed',
  'error_not_found': 'Not found',
  'error_server': 'Server error',
  'error_timeout': 'Request timed out',

  // --- Time/Date ---
  'time_minutes': '{count} minutes',
  'time_hours': '{count} hours',
  'time_days': '{count} days',
  'time_today': 'Today',
  'time_tomorrow': 'Tomorrow',
  'time_yesterday': 'Yesterday',

  // --- Misc ---
  'misc_search': 'Search',
  'misc_filter': 'Filter',
  'misc_sort': 'Sort',
  'misc_all': 'All',
  'misc_none': 'None',
  'misc_yes': 'Yes',
  'misc_no': 'No',

  // --- Recall System ---
  'recall_title': 'Preventive Care Reminders',
  'recall_checkup': 'Check-up Examination',
  'recall_vaccination': 'Vaccination Booster',
  'recall_screening': 'Screening',
  'recall_due': 'Due on {date}',
  'recall_overdue': 'Overdue by {days} days',

  // --- Symptom Checker ---
  'symptom_title': 'Symptom Checker',
  'symptom_describe': 'Describe your symptoms',
  'symptom_location': 'Where exactly?',
  'symptom_start': 'Since when?',
  'symptom_intensity': 'Intensity',
  'symptom_result_urgent': 'Please see a doctor soon',
  'symptom_result_routine': 'Schedule a regular appointment',
  'symptom_result_emergency': 'Call emergency services (112)',
  'symptom_disclaimer':
      'This is not a medical diagnosis. When in doubt, contact your doctor.',

  // --- Lab Results ---
  'lab_title': 'Lab Values',
  'lab_date': 'Test Date',
  'lab_normal': 'Normal Range',
  'lab_value': 'Your Value',
  'lab_status_normal': 'Within Normal Range',
  'lab_status_high': 'Elevated',
  'lab_status_low': 'Low',
  'lab_trend': 'Trend',
  'lab_no_results': 'No lab results available',

  // --- Medication Plan ---
  'medication_title': 'Medication Plan',
  'medication_name': 'Medication',
  'medication_dose': 'Dosage',
  'medication_frequency': 'Frequency',
  'medication_morning': 'Morning',
  'medication_noon': 'Noon',
  'medication_evening': 'Evening',
  'medication_night': 'Night',
  'medication_notes': 'Notes',
  'medication_refill': 'Request Refill',

  // --- Vaccination Pass ---
  'vaccination_title': 'Vaccination Record',
  'vaccination_name': 'Vaccination',
  'vaccination_date': 'Vaccination Date',
  'vaccination_next': 'Next Booster',
  'vaccination_batch': 'Batch Number',
  'vaccination_doctor': 'Administering Doctor',
  'vaccination_add': 'Add Vaccination',
  'vaccination_reminder': 'Enable Reminder',

  // --- Forms ---
  'form_title': 'Forms',
  'form_fill': 'Fill Form',
  'form_submit': 'Submit Form',
  'form_save_draft': 'Save Draft',
  'form_required_fields': 'Required fields marked with *',

  // --- Accessibility ---
  'a11y_increase_text': 'Increase Text Size',
  'a11y_decrease_text': 'Decrease Text Size',
  'a11y_high_contrast': 'High Contrast',
  'a11y_screen_reader': 'Screen Reader Mode',
};
