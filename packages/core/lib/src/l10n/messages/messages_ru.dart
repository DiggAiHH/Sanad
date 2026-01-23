// =============================================================================
// RUSSIAN (ru_RU)
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Отправить',
  'button_cancel': 'Отмена',
  'button_save': 'Сохранить',
  'button_delete': 'Удалить',
  'button_edit': 'Редактировать',
  'button_back': 'Назад',
  'button_next': 'Далее',
  'button_close': 'Закрыть',
  'button_confirm': 'Подтвердить',
  'button_retry': 'Повторить',
  'button_refresh': 'Обновить',
  'button_login': 'Войти',
  'button_logout': 'Выйти',
  'button_register': 'Регистрация',

  // --- Navigation ---
  'nav_home': 'Главная',
  'nav_settings': 'Настройки',
  'nav_profile': 'Профиль',
  'nav_help': 'Помощь',

  // --- Status ---
  'status_loading': 'Загрузка...',
  'status_error': 'Произошла ошибка',
  'status_success': 'Успешно',
  'status_empty': 'Нет данных',
  'status_offline': 'Офлайн',
  'status_online': 'Онлайн',

  // --- Validation ---
  'validation_required': 'Это поле обязательно',
  'validation_email': 'Введите корректный email',
  'validation_min_length': 'Минимум {min} символов',
  'validation_max_length': 'Максимум {max} символов',
  'validation_phone': 'Введите корректный номер телефона',

  // --- Auth ---
  'auth_email': 'Электронная почта',
  'auth_password': 'Пароль',
  'auth_forgot_password': 'Забыли пароль?',
  'auth_login_title': 'Вход',
  'auth_register_title': 'Создать аккаунт',
  'auth_welcome': 'С возвращением!',

  // --- Queue/Ticket ---
  'ticket_number': 'Номер талона',
  'ticket_status': 'Статус',
  'ticket_status_waiting': 'Ожидание',
  'ticket_status_called': 'Вызван',
  'ticket_status_in_progress': 'На приёме',
  'ticket_status_completed': 'Завершён',
  'ticket_status_cancelled': 'Отменён',
  'ticket_wait_time': 'Ожидаемое время ожидания',
  'ticket_position': 'Позиция в очереди',
  'queue_title': 'Очередь',
  'queue_empty': 'Очередь пуста',

  // --- Appointments ---
  'appointment_title': 'Записи',
  'appointment_book': 'Записаться',
  'appointment_cancel': 'Отменить запись',
  'appointment_reschedule': 'Перенести',
  'appointment_confirmed': 'Запись подтверждена',
  'appointment_date': 'Дата',
  'appointment_time': 'Время',
  'appointment_doctor': 'Врач',
  'appointment_reason': 'Причина визита',
  'appointment_no_upcoming': 'Нет предстоящих записей',

  // --- Documents ---
  'doc_request_title': 'Запросы документов',
  'doc_prescription': 'Рецепт',
  'doc_sick_note': 'Больничный лист',
  'doc_referral': 'Направление',
  'doc_certificate': 'Справка',
  'doc_status_pending': 'В обработке',
  'doc_status_ready': 'Готово к получению',
  'doc_status_rejected': 'Отклонено',

  // --- Consultation ---
  'consultation_title': 'Консультация',
  'consultation_video': 'Видеоконсультация',
  'consultation_phone': 'Телефонная консультация',
  'consultation_chat': 'Чат',
  'consultation_callback': 'Запросить обратный звонок',
  'consultation_start': 'Начать консультацию',
  'consultation_end': 'Завершить консультацию',
  'consultation_waiting': 'Ожидание врача...',

  // --- Medical Data ---
  'med_lab_results': 'Результаты анализов',
  'med_findings': 'Заключения',
  'med_medications': 'Лекарства',
  'med_vaccinations': 'Прививки',
  'med_history': 'История болезни',
  'med_allergies': 'Аллергии',

  // --- Anamnesis ---
  'anamnesis_title': 'Анамнез',
  'anamnesis_start': 'Начать опрос',
  'anamnesis_complete': 'Завершить опрос',
  'anamnesis_symptoms': 'Симптомы',
  'anamnesis_duration': 'Как давно беспокоят симптомы?',
  'anamnesis_severity': 'Насколько сильные симптомы? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Информация о клинике',
  'practice_hours': 'Часы работы',
  'practice_address': 'Адрес',
  'practice_phone': 'Телефон',
  'practice_emergency': 'Экстренная помощь: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Конфиденциальность',
  'privacy_consent': 'Я согласен на обработку моих данных',
  'privacy_data_export': 'Экспортировать мои данные',
  'privacy_data_delete': 'Удалить мои данные',
  'privacy_consent_revoke': 'Отозвать согласие',

  // --- Errors ---
  'error_generic': 'Произошла непредвиденная ошибка',
  'error_network': 'Нет подключения к интернету',
  'error_auth': 'Ошибка авторизации',
  'error_not_found': 'Не найдено',
  'error_server': 'Ошибка сервера',
  'error_timeout': 'Превышено время ожидания',

  // --- Time/Date ---
  'time_minutes': '{count} минут',
  'time_hours': '{count} часов',
  'time_days': '{count} дней',
  'time_today': 'Сегодня',
  'time_tomorrow': 'Завтра',
  'time_yesterday': 'Вчера',

  // --- Misc ---
  'misc_search': 'Поиск',
  'misc_filter': 'Фильтр',
  'misc_sort': 'Сортировка',
  'misc_all': 'Все',
  'misc_none': 'Нет',
  'misc_yes': 'Да',
  'misc_no': 'Нет',

  // --- Recall System ---
  'recall_title': 'Напоминания о профилактике',
  'recall_checkup': 'Общий осмотр',
  'recall_vaccination': 'Напоминание о прививке',
  'recall_screening': 'Скрининг',
  'recall_due': 'Срок: {date}',
  'recall_overdue': 'Просрочено на {days} дней',

  // --- Symptom Checker ---
  'symptom_title': 'Проверка симптомов',
  'symptom_describe': 'Опишите ваши симптомы',
  'symptom_location': 'Где именно?',
  'symptom_start': 'С какого времени?',
  'symptom_intensity': 'Интенсивность',
  'symptom_result_urgent': 'Пожалуйста, обратитесь к врачу в ближайшее время',
  'symptom_result_routine': 'Запишитесь на обычный приём',
  'symptom_result_emergency': 'Вызовите скорую помощь (112)',
  'symptom_disclaimer':
      'Это не медицинский диагноз. При сомнениях обратитесь к врачу.',

  // --- Lab Results ---
  'lab_title': 'Результаты анализов',
  'lab_date': 'Дата анализа',
  'lab_normal': 'Норма',
  'lab_value': 'Ваше значение',
  'lab_status_normal': 'В пределах нормы',
  'lab_status_high': 'Повышен',
  'lab_status_low': 'Понижен',
  'lab_trend': 'Динамика',
  'lab_no_results': 'Нет результатов анализов',

  // --- Medication Plan ---
  'medication_title': 'План приёма лекарств',
  'medication_name': 'Лекарство',
  'medication_dose': 'Дозировка',
  'medication_frequency': 'Частота',
  'medication_morning': 'Утром',
  'medication_noon': 'Днём',
  'medication_evening': 'Вечером',
  'medication_night': 'На ночь',
  'medication_notes': 'Примечания',
  'medication_refill': 'Запросить повторный рецепт',

  // --- Vaccination Pass ---
  'vaccination_title': 'Прививочный сертификат',
  'vaccination_name': 'Прививка',
  'vaccination_date': 'Дата прививки',
  'vaccination_next': 'Следующая ревакцинация',
  'vaccination_batch': 'Номер партии',
  'vaccination_doctor': 'Врач',
  'vaccination_add': 'Добавить прививку',
  'vaccination_reminder': 'Включить напоминание',

  // --- Forms ---
  'form_title': 'Формы',
  'form_fill': 'Заполнить форму',
  'form_submit': 'Отправить форму',
  'form_save_draft': 'Сохранить черновик',
  'form_required_fields': 'Обязательные поля отмечены *',

  // --- Accessibility ---
  'a11y_increase_text': 'Увеличить текст',
  'a11y_decrease_text': 'Уменьшить текст',
  'a11y_high_contrast': 'Высокий контраст',
  'a11y_screen_reader': 'Режим чтения с экрана',
};
