// =============================================================================
// SPANISH (es_ES)
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Enviar',
  'button_cancel': 'Cancelar',
  'button_save': 'Guardar',
  'button_delete': 'Eliminar',
  'button_edit': 'Editar',
  'button_back': 'Atrás',
  'button_next': 'Siguiente',
  'button_close': 'Cerrar',
  'button_confirm': 'Confirmar',
  'button_retry': 'Reintentar',
  'button_refresh': 'Actualizar',
  'button_login': 'Iniciar sesión',
  'button_logout': 'Cerrar sesión',
  'button_register': 'Registrarse',

  // --- Navigation ---
  'nav_home': 'Inicio',
  'nav_settings': 'Configuración',
  'nav_profile': 'Perfil',
  'nav_help': 'Ayuda',

  // --- Status ---
  'status_loading': 'Cargando...',
  'status_error': 'Se produjo un error',
  'status_success': 'Éxito',
  'status_empty': 'No hay datos disponibles',
  'status_offline': 'Sin conexión',
  'status_online': 'En línea',

  // --- Validation ---
  'validation_required': 'Este campo es obligatorio',
  'validation_email': 'Por favor, introduzca un email válido',
  'validation_min_length': 'Mínimo {min} caracteres requeridos',
  'validation_max_length': 'Máximo {max} caracteres permitidos',
  'validation_phone': 'Por favor, introduzca un número de teléfono válido',

  // --- Auth ---
  'auth_email': 'Correo electrónico',
  'auth_password': 'Contraseña',
  'auth_forgot_password': '¿Olvidó su contraseña?',
  'auth_login_title': 'Iniciar sesión',
  'auth_register_title': 'Crear cuenta',
  'auth_welcome': '¡Bienvenido de nuevo!',

  // --- Queue/Ticket ---
  'ticket_number': 'Número de turno',
  'ticket_status': 'Estado',
  'ticket_status_waiting': 'Esperando',
  'ticket_status_called': 'Llamado',
  'ticket_status_in_progress': 'En proceso',
  'ticket_status_completed': 'Completado',
  'ticket_status_cancelled': 'Cancelado',
  'ticket_wait_time': 'Tiempo de espera estimado',
  'ticket_position': 'Posición en la cola',
  'queue_title': 'Cola de espera',
  'queue_empty': 'La cola está vacía',

  // --- Appointments ---
  'appointment_title': 'Citas',
  'appointment_book': 'Reservar cita',
  'appointment_cancel': 'Cancelar cita',
  'appointment_reschedule': 'Reprogramar',
  'appointment_confirmed': 'Cita confirmada',
  'appointment_date': 'Fecha',
  'appointment_time': 'Hora',
  'appointment_doctor': 'Médico',
  'appointment_reason': 'Motivo de la visita',
  'appointment_no_upcoming': 'No hay citas próximas',

  // --- Documents ---
  'doc_request_title': 'Solicitudes de documentos',
  'doc_prescription': 'Receta',
  'doc_sick_note': 'Baja médica',
  'doc_referral': 'Derivación',
  'doc_certificate': 'Certificado',
  'doc_status_pending': 'Pendiente',
  'doc_status_ready': 'Listo para recoger',
  'doc_status_rejected': 'Rechazado',

  // --- Consultation ---
  'consultation_title': 'Consulta',
  'consultation_video': 'Videoconsulta',
  'consultation_phone': 'Consulta telefónica',
  'consultation_chat': 'Chat',
  'consultation_callback': 'Solicitar llamada',
  'consultation_start': 'Iniciar consulta',
  'consultation_end': 'Finalizar consulta',
  'consultation_waiting': 'Esperando al médico...',

  // --- Medical Data ---
  'med_lab_results': 'Resultados de laboratorio',
  'med_findings': 'Hallazgos',
  'med_medications': 'Medicamentos',
  'med_vaccinations': 'Vacunas',
  'med_history': 'Historial médico',
  'med_allergies': 'Alergias',

  // --- Anamnesis ---
  'anamnesis_title': 'Anamnesis',
  'anamnesis_start': 'Iniciar cuestionario',
  'anamnesis_complete': 'Completar cuestionario',
  'anamnesis_symptoms': 'Síntomas',
  'anamnesis_duration': '¿Desde cuándo tiene estos síntomas?',
  'anamnesis_severity': '¿Qué tan severos son los síntomas? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Información de la consulta',
  'practice_hours': 'Horario de atención',
  'practice_address': 'Dirección',
  'practice_phone': 'Teléfono',
  'practice_emergency': 'Emergencias: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Privacidad',
  'privacy_consent': 'Acepto el procesamiento de mis datos',
  'privacy_data_export': 'Exportar mis datos',
  'privacy_data_delete': 'Eliminar mis datos',
  'privacy_consent_revoke': 'Revocar consentimiento',

  // --- Errors ---
  'error_generic': 'Se produjo un error inesperado',
  'error_network': 'Sin conexión a Internet',
  'error_auth': 'Error de autenticación',
  'error_not_found': 'No encontrado',
  'error_server': 'Error del servidor',
  'error_timeout': 'Tiempo de espera agotado',

  // --- Time/Date ---
  'time_minutes': '{count} minutos',
  'time_hours': '{count} horas',
  'time_days': '{count} días',
  'time_today': 'Hoy',
  'time_tomorrow': 'Mañana',
  'time_yesterday': 'Ayer',

  // --- Misc ---
  'misc_search': 'Buscar',
  'misc_filter': 'Filtrar',
  'misc_sort': 'Ordenar',
  'misc_all': 'Todos',
  'misc_none': 'Ninguno',
  'misc_yes': 'Sí',
  'misc_no': 'No',

  // --- Recall System ---
  'recall_title': 'Recordatorios de prevención',
  'recall_checkup': 'Revisión médica',
  'recall_vaccination': 'Recordatorio de vacunación',
  'recall_screening': 'Examen preventivo',
  'recall_due': 'Programado para {date}',
  'recall_overdue': 'Vencido hace {days} días',

  // --- Symptom Checker ---
  'symptom_title': 'Verificador de síntomas',
  'symptom_describe': 'Describa sus síntomas',
  'symptom_location': '¿Dónde exactamente?',
  'symptom_start': '¿Desde cuándo?',
  'symptom_intensity': 'Intensidad',
  'symptom_result_urgent': 'Por favor, consulte a un médico pronto',
  'symptom_result_routine': 'Programe una cita regular',
  'symptom_result_emergency': 'Llame a emergencias (112)',
  'symptom_disclaimer':
      'Esto no es un diagnóstico médico. En caso de duda, consulte a su médico.',

  // --- Lab Results ---
  'lab_title': 'Valores de laboratorio',
  'lab_date': 'Fecha del análisis',
  'lab_normal': 'Rango normal',
  'lab_value': 'Su valor',
  'lab_status_normal': 'Dentro del rango normal',
  'lab_status_high': 'Elevado',
  'lab_status_low': 'Bajo',
  'lab_trend': 'Tendencia',
  'lab_no_results': 'Sin resultados de laboratorio',

  // --- Medication Plan ---
  'medication_title': 'Plan de medicación',
  'medication_name': 'Medicamento',
  'medication_dose': 'Dosis',
  'medication_frequency': 'Frecuencia',
  'medication_morning': 'Mañana',
  'medication_noon': 'Mediodía',
  'medication_evening': 'Tarde',
  'medication_night': 'Noche',
  'medication_notes': 'Notas',
  'medication_refill': 'Solicitar renovación',

  // --- Vaccination Pass ---
  'vaccination_title': 'Cartilla de vacunación',
  'vaccination_name': 'Vacuna',
  'vaccination_date': 'Fecha de vacunación',
  'vaccination_next': 'Próximo refuerzo',
  'vaccination_batch': 'Número de lote',
  'vaccination_doctor': 'Médico vacunador',
  'vaccination_add': 'Añadir vacuna',
  'vaccination_reminder': 'Activar recordatorio',

  // --- Forms ---
  'form_title': 'Formularios',
  'form_fill': 'Rellenar formulario',
  'form_submit': 'Enviar formulario',
  'form_save_draft': 'Guardar borrador',
  'form_required_fields': 'Campos obligatorios marcados con *',

  // --- Accessibility ---
  'a11y_increase_text': 'Aumentar tamaño de texto',
  'a11y_decrease_text': 'Reducir tamaño de texto',
  'a11y_high_contrast': 'Alto contraste',
  'a11y_screen_reader': 'Modo lector de pantalla',
};
