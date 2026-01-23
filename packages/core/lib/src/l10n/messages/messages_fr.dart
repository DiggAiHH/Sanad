// =============================================================================
// FRENCH (fr_FR)
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Envoyer',
  'button_cancel': 'Annuler',
  'button_save': 'Enregistrer',
  'button_delete': 'Supprimer',
  'button_edit': 'Modifier',
  'button_back': 'Retour',
  'button_next': 'Suivant',
  'button_close': 'Fermer',
  'button_confirm': 'Confirmer',
  'button_retry': 'Réessayer',
  'button_refresh': 'Actualiser',
  'button_login': 'Se connecter',
  'button_logout': 'Se déconnecter',
  'button_register': "S'inscrire",

  // --- Navigation ---
  'nav_home': 'Accueil',
  'nav_settings': 'Paramètres',
  'nav_profile': 'Profil',
  'nav_help': 'Aide',

  // --- Status ---
  'status_loading': 'Chargement...',
  'status_error': 'Une erreur est survenue',
  'status_success': 'Succès',
  'status_empty': 'Aucune donnée disponible',
  'status_offline': 'Hors ligne',
  'status_online': 'En ligne',

  // --- Validation ---
  'validation_required': 'Ce champ est obligatoire',
  'validation_email': 'Veuillez entrer une adresse email valide',
  'validation_min_length': 'Minimum {min} caractères requis',
  'validation_max_length': 'Maximum {max} caractères autorisés',
  'validation_phone': 'Veuillez entrer un numéro de téléphone valide',

  // --- Auth ---
  'auth_email': 'Adresse email',
  'auth_password': 'Mot de passe',
  'auth_forgot_password': 'Mot de passe oublié ?',
  'auth_login_title': 'Connexion',
  'auth_register_title': 'Créer un compte',
  'auth_welcome': 'Bienvenue !',

  // --- Queue/Ticket ---
  'ticket_number': 'Numéro de ticket',
  'ticket_status': 'Statut',
  'ticket_status_waiting': 'En attente',
  'ticket_status_called': 'Appelé',
  'ticket_status_in_progress': 'En cours',
  'ticket_status_completed': 'Terminé',
  'ticket_status_cancelled': 'Annulé',
  'ticket_wait_time': "Temps d'attente estimé",
  'ticket_position': "Position dans la file d'attente",
  'queue_title': "File d'attente",
  'queue_empty': "La file d'attente est vide",

  // --- Appointments ---
  'appointment_title': 'Rendez-vous',
  'appointment_book': 'Prendre rendez-vous',
  'appointment_cancel': 'Annuler le rendez-vous',
  'appointment_reschedule': 'Reprogrammer',
  'appointment_confirmed': 'Rendez-vous confirmé',
  'appointment_date': 'Date',
  'appointment_time': 'Heure',
  'appointment_doctor': 'Médecin',
  'appointment_reason': 'Motif de la visite',
  'appointment_no_upcoming': 'Aucun rendez-vous à venir',

  // --- Documents ---
  'doc_request_title': 'Demandes de documents',
  'doc_prescription': 'Ordonnance',
  'doc_sick_note': 'Arrêt maladie',
  'doc_referral': 'Orientation',
  'doc_certificate': 'Certificat',
  'doc_status_pending': 'En traitement',
  'doc_status_ready': 'Prêt à retirer',
  'doc_status_rejected': 'Refusé',

  // --- Consultation ---
  'consultation_title': 'Consultation',
  'consultation_video': 'Consultation vidéo',
  'consultation_phone': 'Consultation téléphonique',
  'consultation_chat': 'Chat',
  'consultation_callback': 'Demander un rappel',
  'consultation_start': 'Démarrer la consultation',
  'consultation_end': 'Terminer la consultation',
  'consultation_waiting': 'En attente du médecin...',

  // --- Medical Data ---
  'med_lab_results': 'Résultats de laboratoire',
  'med_findings': 'Résultats',
  'med_medications': 'Médicaments',
  'med_vaccinations': 'Vaccinations',
  'med_history': 'Historique médical',
  'med_allergies': 'Allergies',

  // --- Anamnesis ---
  'anamnesis_title': 'Anamnèse',
  'anamnesis_start': 'Commencer le questionnaire',
  'anamnesis_complete': 'Terminer le questionnaire',
  'anamnesis_symptoms': 'Symptômes',
  'anamnesis_duration': 'Depuis quand avez-vous ces symptômes ?',
  'anamnesis_severity': 'Quelle est la gravité des symptômes ? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Informations sur le cabinet',
  'practice_hours': "Heures d'ouverture",
  'practice_address': 'Adresse',
  'practice_phone': 'Téléphone',
  'practice_emergency': 'Urgences : 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Confidentialité',
  'privacy_consent': "J'accepte le traitement de mes données",
  'privacy_data_export': 'Exporter mes données',
  'privacy_data_delete': 'Supprimer mes données',
  'privacy_consent_revoke': 'Révoquer le consentement',

  // --- Errors ---
  'error_generic': 'Une erreur inattendue est survenue',
  'error_network': 'Pas de connexion Internet',
  'error_auth': "Échec de l'authentification",
  'error_not_found': 'Non trouvé',
  'error_server': 'Erreur serveur',
  'error_timeout': 'Délai dépassé',

  // --- Time/Date ---
  'time_minutes': '{count} minutes',
  'time_hours': '{count} heures',
  'time_days': '{count} jours',
  'time_today': "Aujourd'hui",
  'time_tomorrow': 'Demain',
  'time_yesterday': 'Hier',

  // --- Misc ---
  'misc_search': 'Rechercher',
  'misc_filter': 'Filtrer',
  'misc_sort': 'Trier',
  'misc_all': 'Tous',
  'misc_none': 'Aucun',
  'misc_yes': 'Oui',
  'misc_no': 'Non',

  // --- Recall System ---
  'recall_title': 'Rappels de prévention',
  'recall_checkup': 'Bilan de santé',
  'recall_vaccination': 'Rappel de vaccination',
  'recall_screening': 'Dépistage',
  'recall_due': 'Prévu le {date}',
  'recall_overdue': 'En retard de {days} jours',

  // --- Symptom Checker ---
  'symptom_title': 'Vérificateur de symptômes',
  'symptom_describe': 'Décrivez vos symptômes',
  'symptom_location': 'Où exactement ?',
  'symptom_start': 'Depuis quand ?',
  'symptom_intensity': 'Intensité',
  'symptom_result_urgent': 'Veuillez consulter un médecin rapidement',
  'symptom_result_routine': 'Prenez un rendez-vous régulier',
  'symptom_result_emergency': 'Appelez les urgences (112)',
  'symptom_disclaimer':
      "Ceci n'est pas un diagnostic médical. En cas de doute, consultez votre médecin.",

  // --- Lab Results ---
  'lab_title': 'Valeurs de laboratoire',
  'lab_date': 'Date du test',
  'lab_normal': 'Plage normale',
  'lab_value': 'Votre valeur',
  'lab_status_normal': 'Dans la normale',
  'lab_status_high': 'Élevé',
  'lab_status_low': 'Bas',
  'lab_trend': 'Tendance',
  'lab_no_results': 'Aucun résultat de laboratoire',

  // --- Medication Plan ---
  'medication_title': 'Plan de médication',
  'medication_name': 'Médicament',
  'medication_dose': 'Dosage',
  'medication_frequency': 'Fréquence',
  'medication_morning': 'Matin',
  'medication_noon': 'Midi',
  'medication_evening': 'Soir',
  'medication_night': 'Nuit',
  'medication_notes': 'Notes',
  'medication_refill': 'Demander un renouvellement',

  // --- Vaccination Pass ---
  'vaccination_title': 'Carnet de vaccination',
  'vaccination_name': 'Vaccination',
  'vaccination_date': 'Date de vaccination',
  'vaccination_next': 'Prochain rappel',
  'vaccination_batch': 'Numéro de lot',
  'vaccination_doctor': 'Médecin vaccinateur',
  'vaccination_add': 'Ajouter une vaccination',
  'vaccination_reminder': 'Activer le rappel',

  // --- Forms ---
  'form_title': 'Formulaires',
  'form_fill': 'Remplir le formulaire',
  'form_submit': 'Soumettre le formulaire',
  'form_save_draft': 'Enregistrer le brouillon',
  'form_required_fields': 'Champs obligatoires marqués par *',

  // --- Accessibility ---
  'a11y_increase_text': 'Agrandir le texte',
  'a11y_decrease_text': 'Réduire le texte',
  'a11y_high_contrast': 'Contraste élevé',
  'a11y_screen_reader': "Mode lecteur d'écran",
};
