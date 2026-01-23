// =============================================================================
// SANAD L10N - Lokalisierungs-Infrastruktur
// =============================================================================
// Zentrale Lokalisierungs-Klasse für alle Sanad Apps.
// Unterstützt: DE, EN, TR, AR, RU, PL, FR, ES (8 Sprachen)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages/messages_de.dart' as de;
import 'messages/messages_en.dart' as en;
import 'messages/messages_tr.dart' as tr;
import 'messages/messages_ar.dart' as ar;
import 'messages/messages_ru.dart' as ru;
import 'messages/messages_pl.dart' as pl;
import 'messages/messages_fr.dart' as fr;
import 'messages/messages_es.dart' as es;

/// Unterstützte Locales für Sanad
class SanadLocales {
  static const Locale de = Locale('de', 'DE');
  static const Locale en = Locale('en', 'US');
  static const Locale tr = Locale('tr', 'TR');
  static const Locale ar = Locale('ar', 'SA');
  static const Locale ru = Locale('ru', 'RU');
  static const Locale pl = Locale('pl', 'PL');
  static const Locale fr = Locale('fr', 'FR');
  static const Locale es = Locale('es', 'ES');

  static const List<Locale> supportedLocales = [de, en, tr, ar, ru, pl, fr, es];

  /// RTL-Sprachen (Arabisch)
  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}

/// Lokalisierungs-Delegate für MaterialApp
class SanadLocalizationsDelegate
    extends LocalizationsDelegate<SanadLocalizations> {
  const SanadLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SanadLocales.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<SanadLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.toString();
    return SanadLocalizations(locale);
  }

  @override
  bool shouldReload(SanadLocalizationsDelegate old) => false;
}

/// Hauptklasse für alle lokalisierten Strings
class SanadLocalizations {
  final Locale locale;

  SanadLocalizations(this.locale);

  /// Zugriff via BuildContext
  static SanadLocalizations of(BuildContext context) {
    return Localizations.of<SanadLocalizations>(context, SanadLocalizations)!;
  }

  /// Delegate für MaterialApp.localizationsDelegates
  static const LocalizationsDelegate<SanadLocalizations> delegate =
      SanadLocalizationsDelegate();

  /// Prüft ob aktuelle Locale RTL ist
  bool get isRtl => SanadLocales.isRtl(locale);

  /// Gibt die TextDirection basierend auf Locale zurück
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  // ============================================================================
  // MESSAGE LOOKUP
  // ============================================================================

  Map<String, String> get _messages {
    switch (locale.languageCode) {
      case 'de':
        return de.messages;
      case 'en':
        return en.messages;
      case 'tr':
        return tr.messages;
      case 'ar':
        return ar.messages;
      case 'ru':
        return ru.messages;
      case 'pl':
        return pl.messages;
      case 'fr':
        return fr.messages;
      case 'es':
        return es.messages;
      default:
        return de.messages; // Fallback: Deutsch
    }
  }

  /// Holt einen lokalisierten String mit optionalen Parametern
  String translate(String key, [Map<String, dynamic>? params]) {
    String text = _messages[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value.toString());
      });
    }

    return text;
  }

  // ============================================================================
  // COMMON LABELS
  // ============================================================================

  // --- App-weite Buttons ---
  String get buttonSubmit => translate('button_submit');
  String get buttonCancel => translate('button_cancel');
  String get buttonSave => translate('button_save');
  String get buttonDelete => translate('button_delete');
  String get buttonEdit => translate('button_edit');
  String get buttonBack => translate('button_back');
  String get buttonNext => translate('button_next');
  String get buttonClose => translate('button_close');
  String get buttonConfirm => translate('button_confirm');
  String get buttonRetry => translate('button_retry');
  String get buttonRefresh => translate('button_refresh');
  String get buttonLogin => translate('button_login');
  String get buttonLogout => translate('button_logout');
  String get buttonRegister => translate('button_register');

  // --- Navigation ---
  String get navHome => translate('nav_home');
  String get navSettings => translate('nav_settings');
  String get navProfile => translate('nav_profile');
  String get navHelp => translate('nav_help');

  // --- Status & Feedback ---
  String get statusLoading => translate('status_loading');
  String get statusError => translate('status_error');
  String get statusSuccess => translate('status_success');
  String get statusEmpty => translate('status_empty');
  String get statusOffline => translate('status_offline');
  String get statusOnline => translate('status_online');

  // --- Validierung ---
  String get validationRequired => translate('validation_required');
  String get validationEmail => translate('validation_email');
  String get validationMinLength => translate('validation_min_length');
  String get validationMaxLength => translate('validation_max_length');
  String get validationPhone => translate('validation_phone');

  // --- Auth ---
  String get authEmail => translate('auth_email');
  String get authPassword => translate('auth_password');
  String get authForgotPassword => translate('auth_forgot_password');
  String get authLoginTitle => translate('auth_login_title');
  String get authRegisterTitle => translate('auth_register_title');
  String get authWelcome => translate('auth_welcome');

  // --- Queue/Ticket ---
  String get ticketNumber => translate('ticket_number');
  String get ticketStatus => translate('ticket_status');
  String get ticketStatusWaiting => translate('ticket_status_waiting');
  String get ticketStatusCalled => translate('ticket_status_called');
  String get ticketStatusInProgress => translate('ticket_status_in_progress');
  String get ticketStatusCompleted => translate('ticket_status_completed');
  String get ticketStatusCancelled => translate('ticket_status_cancelled');
  String get ticketWaitTime => translate('ticket_wait_time');
  String get ticketPosition => translate('ticket_position');
  String get queueTitle => translate('queue_title');
  String get queueEmpty => translate('queue_empty');

  // --- Appointments ---
  String get appointmentTitle => translate('appointment_title');
  String get appointmentBook => translate('appointment_book');
  String get appointmentCancel => translate('appointment_cancel');
  String get appointmentReschedule => translate('appointment_reschedule');
  String get appointmentConfirmed => translate('appointment_confirmed');
  String get appointmentDate => translate('appointment_date');
  String get appointmentTime => translate('appointment_time');
  String get appointmentDoctor => translate('appointment_doctor');
  String get appointmentReason => translate('appointment_reason');
  String get appointmentNoUpcoming => translate('appointment_no_upcoming');

  // --- Documents ---
  String get docRequestTitle => translate('doc_request_title');
  String get docPrescription => translate('doc_prescription');
  String get docSickNote => translate('doc_sick_note');
  String get docReferral => translate('doc_referral');
  String get docCertificate => translate('doc_certificate');
  String get docStatusPending => translate('doc_status_pending');
  String get docStatusReady => translate('doc_status_ready');
  String get docStatusRejected => translate('doc_status_rejected');

  // --- Consultation ---
  String get consultationTitle => translate('consultation_title');
  String get consultationVideo => translate('consultation_video');
  String get consultationPhone => translate('consultation_phone');
  String get consultationChat => translate('consultation_chat');
  String get consultationCallback => translate('consultation_callback');
  String get consultationStart => translate('consultation_start');
  String get consultationEnd => translate('consultation_end');
  String get consultationWaiting => translate('consultation_waiting');

  // --- Medical Data ---
  String get medLabResults => translate('med_lab_results');
  String get medFindings => translate('med_findings');
  String get medMedications => translate('med_medications');
  String get medVaccinations => translate('med_vaccinations');
  String get medHistory => translate('med_history');
  String get medAllergies => translate('med_allergies');

  // --- Anamnesis ---
  String get anamnesisTitle => translate('anamnesis_title');
  String get anamnesisStart => translate('anamnesis_start');
  String get anamnesisComplete => translate('anamnesis_complete');
  String get anamnesisSymptoms => translate('anamnesis_symptoms');
  String get anamnesisDuration => translate('anamnesis_duration');
  String get anamnesisSeverity => translate('anamnesis_severity');

  // --- Practice Info ---
  String get practiceInfo => translate('practice_info');
  String get practiceHours => translate('practice_hours');
  String get practiceAddress => translate('practice_address');
  String get practicePhone => translate('practice_phone');
  String get practiceEmergency => translate('practice_emergency');

  // --- Privacy/DSGVO ---
  String get privacyTitle => translate('privacy_title');
  String get privacyConsent => translate('privacy_consent');
  String get privacyDataExport => translate('privacy_data_export');
  String get privacyDataDelete => translate('privacy_data_delete');
  String get privacyConsentRevoke => translate('privacy_consent_revoke');

  // --- Errors ---
  String get errorGeneric => translate('error_generic');
  String get errorNetwork => translate('error_network');
  String get errorAuth => translate('error_auth');
  String get errorNotFound => translate('error_not_found');
  String get errorServer => translate('error_server');
  String get errorTimeout => translate('error_timeout');

  // --- Time/Date ---
  String get timeMinutes => translate('time_minutes');
  String get timeHours => translate('time_hours');
  String get timeDays => translate('time_days');
  String get timeToday => translate('time_today');
  String get timeTomorrow => translate('time_tomorrow');
  String get timeYesterday => translate('time_yesterday');

  // --- Misc ---
  String get miscSearch => translate('misc_search');
  String get miscFilter => translate('misc_filter');
  String get miscSort => translate('misc_sort');
  String get miscAll => translate('misc_all');
  String get miscNone => translate('misc_none');
  String get miscYes => translate('misc_yes');
  String get miscNo => translate('misc_no');
}

/// Extension für einfachen Zugriff via context.l10n
extension SanadLocalizationsExtension on BuildContext {
  SanadLocalizations get l10n => SanadLocalizations.of(this);
}
