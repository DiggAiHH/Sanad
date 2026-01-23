// =============================================================================
// GERMAN (de_DE) - Basis-Sprache
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Absenden',
  'button_cancel': 'Abbrechen',
  'button_save': 'Speichern',
  'button_delete': 'Löschen',
  'button_edit': 'Bearbeiten',
  'button_back': 'Zurück',
  'button_next': 'Weiter',
  'button_close': 'Schließen',
  'button_confirm': 'Bestätigen',
  'button_retry': 'Erneut versuchen',
  'button_refresh': 'Aktualisieren',
  'button_login': 'Anmelden',
  'button_logout': 'Abmelden',
  'button_register': 'Registrieren',

  // --- Navigation ---
  'nav_home': 'Startseite',
  'nav_settings': 'Einstellungen',
  'nav_profile': 'Profil',
  'nav_help': 'Hilfe',

  // --- Status ---
  'status_loading': 'Lädt...',
  'status_error': 'Fehler aufgetreten',
  'status_success': 'Erfolgreich',
  'status_empty': 'Keine Daten vorhanden',
  'status_offline': 'Offline',
  'status_online': 'Online',

  // --- Validation ---
  'validation_required': 'Dieses Feld ist erforderlich',
  'validation_email': 'Bitte geben Sie eine gültige E-Mail-Adresse ein',
  'validation_min_length': 'Mindestens {min} Zeichen erforderlich',
  'validation_max_length': 'Maximal {max} Zeichen erlaubt',
  'validation_phone': 'Bitte geben Sie eine gültige Telefonnummer ein',

  // --- Auth ---
  'auth_email': 'E-Mail-Adresse',
  'auth_password': 'Passwort',
  'auth_forgot_password': 'Passwort vergessen?',
  'auth_login_title': 'Anmelden',
  'auth_register_title': 'Konto erstellen',
  'auth_welcome': 'Willkommen zurück!',

  // --- Queue/Ticket ---
  'ticket_number': 'Ticket-Nummer',
  'ticket_status': 'Status',
  'ticket_status_waiting': 'Wartend',
  'ticket_status_called': 'Aufgerufen',
  'ticket_status_in_progress': 'In Behandlung',
  'ticket_status_completed': 'Abgeschlossen',
  'ticket_status_cancelled': 'Storniert',
  'ticket_wait_time': 'Geschätzte Wartezeit',
  'ticket_position': 'Position in der Warteschlange',
  'queue_title': 'Warteschlange',
  'queue_empty': 'Die Warteschlange ist leer',

  // --- Appointments ---
  'appointment_title': 'Termine',
  'appointment_book': 'Termin buchen',
  'appointment_cancel': 'Termin absagen',
  'appointment_reschedule': 'Termin verschieben',
  'appointment_confirmed': 'Termin bestätigt',
  'appointment_date': 'Datum',
  'appointment_time': 'Uhrzeit',
  'appointment_doctor': 'Arzt/Ärztin',
  'appointment_reason': 'Grund des Besuchs',
  'appointment_no_upcoming': 'Keine anstehenden Termine',

  // --- Documents ---
  'doc_request_title': 'Dokumentenanfragen',
  'doc_prescription': 'Rezept',
  'doc_sick_note': 'Arbeitsunfähigkeitsbescheinigung',
  'doc_referral': 'Überweisung',
  'doc_certificate': 'Bescheinigung',
  'doc_status_pending': 'In Bearbeitung',
  'doc_status_ready': 'Bereit zur Abholung',
  'doc_status_rejected': 'Abgelehnt',

  // --- Consultation ---
  'consultation_title': 'Sprechstunde',
  'consultation_video': 'Videosprechstunde',
  'consultation_phone': 'Telefonsprechstunde',
  'consultation_chat': 'Chat',
  'consultation_callback': 'Rückruf anfordern',
  'consultation_start': 'Sprechstunde starten',
  'consultation_end': 'Sprechstunde beenden',
  'consultation_waiting': 'Warten auf Arzt...',

  // --- Medical Data ---
  'med_lab_results': 'Laborergebnisse',
  'med_findings': 'Befunde',
  'med_medications': 'Medikamente',
  'med_vaccinations': 'Impfungen',
  'med_history': 'Krankengeschichte',
  'med_allergies': 'Allergien',

  // --- Anamnesis ---
  'anamnesis_title': 'Anamnese',
  'anamnesis_start': 'Anamnese starten',
  'anamnesis_complete': 'Anamnese abschließen',
  'anamnesis_symptoms': 'Symptome',
  'anamnesis_duration': 'Seit wann bestehen die Beschwerden?',
  'anamnesis_severity': 'Wie stark sind die Beschwerden? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Praxisinformationen',
  'practice_hours': 'Öffnungszeiten',
  'practice_address': 'Adresse',
  'practice_phone': 'Telefon',
  'practice_emergency': 'Notfall: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Datenschutz',
  'privacy_consent': 'Ich stimme der Verarbeitung meiner Daten zu',
  'privacy_data_export': 'Meine Daten exportieren',
  'privacy_data_delete': 'Meine Daten löschen',
  'privacy_consent_revoke': 'Einwilligung widerrufen',

  // --- Errors ---
  'error_generic': 'Ein unerwarteter Fehler ist aufgetreten',
  'error_network': 'Keine Internetverbindung',
  'error_auth': 'Anmeldung fehlgeschlagen',
  'error_not_found': 'Nicht gefunden',
  'error_server': 'Serverfehler',
  'error_timeout': 'Zeitüberschreitung',

  // --- Time/Date ---
  'time_minutes': '{count} Minuten',
  'time_hours': '{count} Stunden',
  'time_days': '{count} Tage',
  'time_today': 'Heute',
  'time_tomorrow': 'Morgen',
  'time_yesterday': 'Gestern',

  // --- Misc ---
  'misc_search': 'Suchen',
  'misc_filter': 'Filtern',
  'misc_sort': 'Sortieren',
  'misc_all': 'Alle',
  'misc_none': 'Keine',
  'misc_yes': 'Ja',
  'misc_no': 'Nein',

  // --- Recall System ---
  'recall_title': 'Vorsorge-Erinnerungen',
  'recall_checkup': 'Check-up Untersuchung',
  'recall_vaccination': 'Impfauffrischung',
  'recall_screening': 'Vorsorgeuntersuchung',
  'recall_due': 'Fällig am {date}',
  'recall_overdue': 'Überfällig seit {days} Tagen',

  // --- Symptom Checker ---
  'symptom_title': 'Symptom-Check',
  'symptom_describe': 'Beschreiben Sie Ihre Symptome',
  'symptom_location': 'Wo genau?',
  'symptom_start': 'Seit wann?',
  'symptom_intensity': 'Intensität',
  'symptom_result_urgent': 'Bitte suchen Sie zeitnah einen Arzt auf',
  'symptom_result_routine': 'Vereinbaren Sie einen regulären Termin',
  'symptom_result_emergency': 'Rufen Sie den Notruf (112) an',
  'symptom_disclaimer':
      'Dies ist keine medizinische Diagnose. Im Zweifel kontaktieren Sie Ihren Arzt.',

  // --- Lab Results ---
  'lab_title': 'Laborwerte',
  'lab_date': 'Datum der Untersuchung',
  'lab_normal': 'Normalbereich',
  'lab_value': 'Ihr Wert',
  'lab_status_normal': 'Im Normalbereich',
  'lab_status_high': 'Erhöht',
  'lab_status_low': 'Erniedrigt',
  'lab_trend': 'Verlauf',
  'lab_no_results': 'Keine Laborergebnisse vorhanden',

  // --- Medication Plan ---
  'medication_title': 'Medikamentenplan',
  'medication_name': 'Medikament',
  'medication_dose': 'Dosierung',
  'medication_frequency': 'Einnahme',
  'medication_morning': 'Morgens',
  'medication_noon': 'Mittags',
  'medication_evening': 'Abends',
  'medication_night': 'Nachts',
  'medication_notes': 'Hinweise',
  'medication_refill': 'Nachbestellung anfordern',

  // --- Vaccination Pass ---
  'vaccination_title': 'Impfpass',
  'vaccination_name': 'Impfung',
  'vaccination_date': 'Impfdatum',
  'vaccination_next': 'Nächste Auffrischung',
  'vaccination_batch': 'Chargennummer',
  'vaccination_doctor': 'Impfender Arzt',
  'vaccination_add': 'Impfung hinzufügen',
  'vaccination_reminder': 'Erinnerung aktivieren',

  // --- Forms ---
  'form_title': 'Formulare',
  'form_fill': 'Formular ausfüllen',
  'form_submit': 'Formular absenden',
  'form_save_draft': 'Entwurf speichern',
  'form_required_fields': 'Pflichtfelder mit * markiert',

  // --- Accessibility ---
  'a11y_increase_text': 'Text vergrößern',
  'a11y_decrease_text': 'Text verkleinern',
  'a11y_high_contrast': 'Hoher Kontrast',
  'a11y_screen_reader': 'Screenreader-Modus',
};
