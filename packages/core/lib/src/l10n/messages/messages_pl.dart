// =============================================================================
// POLISH (pl_PL)
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Wyślij',
  'button_cancel': 'Anuluj',
  'button_save': 'Zapisz',
  'button_delete': 'Usuń',
  'button_edit': 'Edytuj',
  'button_back': 'Wstecz',
  'button_next': 'Dalej',
  'button_close': 'Zamknij',
  'button_confirm': 'Potwierdź',
  'button_retry': 'Ponów',
  'button_refresh': 'Odśwież',
  'button_login': 'Zaloguj się',
  'button_logout': 'Wyloguj się',
  'button_register': 'Zarejestruj się',

  // --- Navigation ---
  'nav_home': 'Strona główna',
  'nav_settings': 'Ustawienia',
  'nav_profile': 'Profil',
  'nav_help': 'Pomoc',

  // --- Status ---
  'status_loading': 'Ładowanie...',
  'status_error': 'Wystąpił błąd',
  'status_success': 'Sukces',
  'status_empty': 'Brak danych',
  'status_offline': 'Offline',
  'status_online': 'Online',

  // --- Validation ---
  'validation_required': 'To pole jest wymagane',
  'validation_email': 'Wprowadź prawidłowy adres email',
  'validation_min_length': 'Minimum {min} znaków',
  'validation_max_length': 'Maksimum {max} znaków',
  'validation_phone': 'Wprowadź prawidłowy numer telefonu',

  // --- Auth ---
  'auth_email': 'Adres email',
  'auth_password': 'Hasło',
  'auth_forgot_password': 'Zapomniałeś hasła?',
  'auth_login_title': 'Logowanie',
  'auth_register_title': 'Utwórz konto',
  'auth_welcome': 'Witaj ponownie!',

  // --- Queue/Ticket ---
  'ticket_number': 'Numer biletu',
  'ticket_status': 'Status',
  'ticket_status_waiting': 'Oczekuje',
  'ticket_status_called': 'Wezwany',
  'ticket_status_in_progress': 'W trakcie',
  'ticket_status_completed': 'Zakończony',
  'ticket_status_cancelled': 'Anulowany',
  'ticket_wait_time': 'Szacowany czas oczekiwania',
  'ticket_position': 'Pozycja w kolejce',
  'queue_title': 'Kolejka',
  'queue_empty': 'Kolejka jest pusta',

  // --- Appointments ---
  'appointment_title': 'Wizyty',
  'appointment_book': 'Umów wizytę',
  'appointment_cancel': 'Odwołaj wizytę',
  'appointment_reschedule': 'Przełóż',
  'appointment_confirmed': 'Wizyta potwierdzona',
  'appointment_date': 'Data',
  'appointment_time': 'Godzina',
  'appointment_doctor': 'Lekarz',
  'appointment_reason': 'Powód wizyty',
  'appointment_no_upcoming': 'Brak nadchodzących wizyt',

  // --- Documents ---
  'doc_request_title': 'Wnioski o dokumenty',
  'doc_prescription': 'Recepta',
  'doc_sick_note': 'Zwolnienie lekarskie',
  'doc_referral': 'Skierowanie',
  'doc_certificate': 'Zaświadczenie',
  'doc_status_pending': 'W trakcie realizacji',
  'doc_status_ready': 'Gotowe do odbioru',
  'doc_status_rejected': 'Odrzucone',

  // --- Consultation ---
  'consultation_title': 'Konsultacja',
  'consultation_video': 'Wideokonferencja',
  'consultation_phone': 'Konsultacja telefoniczna',
  'consultation_chat': 'Czat',
  'consultation_callback': 'Poproś o oddzwonienie',
  'consultation_start': 'Rozpocznij konsultację',
  'consultation_end': 'Zakończ konsultację',
  'consultation_waiting': 'Oczekiwanie na lekarza...',

  // --- Medical Data ---
  'med_lab_results': 'Wyniki badań',
  'med_findings': 'Wyniki',
  'med_medications': 'Leki',
  'med_vaccinations': 'Szczepienia',
  'med_history': 'Historia choroby',
  'med_allergies': 'Alergie',

  // --- Anamnesis ---
  'anamnesis_title': 'Wywiad lekarski',
  'anamnesis_start': 'Rozpocznij ankietę',
  'anamnesis_complete': 'Zakończ ankietę',
  'anamnesis_symptoms': 'Objawy',
  'anamnesis_duration': 'Od kiedy występują dolegliwości?',
  'anamnesis_severity': 'Jak silne są dolegliwości? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Informacje o przychodni',
  'practice_hours': 'Godziny otwarcia',
  'practice_address': 'Adres',
  'practice_phone': 'Telefon',
  'practice_emergency': 'Pogotowie: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Prywatność',
  'privacy_consent': 'Zgadzam się na przetwarzanie moich danych',
  'privacy_data_export': 'Eksportuj moje dane',
  'privacy_data_delete': 'Usuń moje dane',
  'privacy_consent_revoke': 'Wycofaj zgodę',

  // --- Errors ---
  'error_generic': 'Wystąpił nieoczekiwany błąd',
  'error_network': 'Brak połączenia z internetem',
  'error_auth': 'Błąd uwierzytelniania',
  'error_not_found': 'Nie znaleziono',
  'error_server': 'Błąd serwera',
  'error_timeout': 'Przekroczono limit czasu',

  // --- Time/Date ---
  'time_minutes': '{count} minut',
  'time_hours': '{count} godzin',
  'time_days': '{count} dni',
  'time_today': 'Dzisiaj',
  'time_tomorrow': 'Jutro',
  'time_yesterday': 'Wczoraj',

  // --- Misc ---
  'misc_search': 'Szukaj',
  'misc_filter': 'Filtruj',
  'misc_sort': 'Sortuj',
  'misc_all': 'Wszystkie',
  'misc_none': 'Brak',
  'misc_yes': 'Tak',
  'misc_no': 'Nie',

  // --- Recall System ---
  'recall_title': 'Przypomnienia o badaniach',
  'recall_checkup': 'Badanie kontrolne',
  'recall_vaccination': 'Przypomnienie o szczepieniu',
  'recall_screening': 'Badanie przesiewowe',
  'recall_due': 'Termin: {date}',
  'recall_overdue': 'Zaległy o {days} dni',

  // --- Symptom Checker ---
  'symptom_title': 'Sprawdzanie objawów',
  'symptom_describe': 'Opisz swoje objawy',
  'symptom_location': 'Gdzie dokładnie?',
  'symptom_start': 'Od kiedy?',
  'symptom_intensity': 'Intensywność',
  'symptom_result_urgent': 'Proszę wkrótce skonsultować się z lekarzem',
  'symptom_result_routine': 'Umów zwykłą wizytę',
  'symptom_result_emergency': 'Zadzwoń pod numer alarmowy (112)',
  'symptom_disclaimer':
      'To nie jest diagnoza medyczna. W razie wątpliwości skontaktuj się z lekarzem.',

  // --- Lab Results ---
  'lab_title': 'Wyniki laboratoryjne',
  'lab_date': 'Data badania',
  'lab_normal': 'Zakres normy',
  'lab_value': 'Twoja wartość',
  'lab_status_normal': 'W normie',
  'lab_status_high': 'Podwyższona',
  'lab_status_low': 'Obniżona',
  'lab_trend': 'Trend',
  'lab_no_results': 'Brak wyników badań',

  // --- Medication Plan ---
  'medication_title': 'Plan leczenia',
  'medication_name': 'Lek',
  'medication_dose': 'Dawka',
  'medication_frequency': 'Częstotliwość',
  'medication_morning': 'Rano',
  'medication_noon': 'W południe',
  'medication_evening': 'Wieczorem',
  'medication_night': 'Na noc',
  'medication_notes': 'Uwagi',
  'medication_refill': 'Zamów powtórkę recepty',

  // --- Vaccination Pass ---
  'vaccination_title': 'Książeczka szczepień',
  'vaccination_name': 'Szczepienie',
  'vaccination_date': 'Data szczepienia',
  'vaccination_next': 'Następne przypomnienie',
  'vaccination_batch': 'Numer partii',
  'vaccination_doctor': 'Lekarz wykonujący',
  'vaccination_add': 'Dodaj szczepienie',
  'vaccination_reminder': 'Włącz przypomnienie',

  // --- Forms ---
  'form_title': 'Formularze',
  'form_fill': 'Wypełnij formularz',
  'form_submit': 'Wyślij formularz',
  'form_save_draft': 'Zapisz wersję roboczą',
  'form_required_fields': 'Pola wymagane oznaczone *',

  // --- Accessibility ---
  'a11y_increase_text': 'Powiększ tekst',
  'a11y_decrease_text': 'Zmniejsz tekst',
  'a11y_high_contrast': 'Wysoki kontrast',
  'a11y_screen_reader': 'Tryb czytnika ekranu',
};
