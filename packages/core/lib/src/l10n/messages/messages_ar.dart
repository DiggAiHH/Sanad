// =============================================================================
// ARABIC (ar_SA) - RTL Language
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'إرسال',
  'button_cancel': 'إلغاء',
  'button_save': 'حفظ',
  'button_delete': 'حذف',
  'button_edit': 'تعديل',
  'button_back': 'رجوع',
  'button_next': 'التالي',
  'button_close': 'إغلاق',
  'button_confirm': 'تأكيد',
  'button_retry': 'إعادة المحاولة',
  'button_refresh': 'تحديث',
  'button_login': 'تسجيل الدخول',
  'button_logout': 'تسجيل الخروج',
  'button_register': 'التسجيل',

  // --- Navigation ---
  'nav_home': 'الصفحة الرئيسية',
  'nav_settings': 'الإعدادات',
  'nav_profile': 'الملف الشخصي',
  'nav_help': 'المساعدة',

  // --- Status ---
  'status_loading': 'جاري التحميل...',
  'status_error': 'حدث خطأ',
  'status_success': 'تم بنجاح',
  'status_empty': 'لا توجد بيانات',
  'status_offline': 'غير متصل',
  'status_online': 'متصل',

  // --- Validation ---
  'validation_required': 'هذا الحقل مطلوب',
  'validation_email': 'يرجى إدخال بريد إلكتروني صحيح',
  'validation_min_length': 'يجب أن يكون {min} أحرف على الأقل',
  'validation_max_length': 'الحد الأقصى {max} حرفاً',
  'validation_phone': 'يرجى إدخال رقم هاتف صحيح',

  // --- Auth ---
  'auth_email': 'البريد الإلكتروني',
  'auth_password': 'كلمة المرور',
  'auth_forgot_password': 'نسيت كلمة المرور؟',
  'auth_login_title': 'تسجيل الدخول',
  'auth_register_title': 'إنشاء حساب',
  'auth_welcome': 'مرحباً بعودتك!',

  // --- Queue/Ticket ---
  'ticket_number': 'رقم التذكرة',
  'ticket_status': 'الحالة',
  'ticket_status_waiting': 'في الانتظار',
  'ticket_status_called': 'تم الاستدعاء',
  'ticket_status_in_progress': 'قيد المعالجة',
  'ticket_status_completed': 'مكتمل',
  'ticket_status_cancelled': 'ملغى',
  'ticket_wait_time': 'وقت الانتظار المتوقع',
  'ticket_position': 'موقعك في الطابور',
  'queue_title': 'قائمة الانتظار',
  'queue_empty': 'قائمة الانتظار فارغة',

  // --- Appointments ---
  'appointment_title': 'المواعيد',
  'appointment_book': 'حجز موعد',
  'appointment_cancel': 'إلغاء الموعد',
  'appointment_reschedule': 'إعادة جدولة',
  'appointment_confirmed': 'تم تأكيد الموعد',
  'appointment_date': 'التاريخ',
  'appointment_time': 'الوقت',
  'appointment_doctor': 'الطبيب',
  'appointment_reason': 'سبب الزيارة',
  'appointment_no_upcoming': 'لا توجد مواعيد قادمة',

  // --- Documents ---
  'doc_request_title': 'طلبات المستندات',
  'doc_prescription': 'وصفة طبية',
  'doc_sick_note': 'شهادة مرضية',
  'doc_referral': 'إحالة',
  'doc_certificate': 'شهادة',
  'doc_status_pending': 'قيد المعالجة',
  'doc_status_ready': 'جاهز للاستلام',
  'doc_status_rejected': 'مرفوض',

  // --- Consultation ---
  'consultation_title': 'الاستشارة',
  'consultation_video': 'استشارة بالفيديو',
  'consultation_phone': 'استشارة هاتفية',
  'consultation_chat': 'محادثة',
  'consultation_callback': 'طلب معاودة الاتصال',
  'consultation_start': 'بدء الاستشارة',
  'consultation_end': 'إنهاء الاستشارة',
  'consultation_waiting': 'في انتظار الطبيب...',

  // --- Medical Data ---
  'med_lab_results': 'نتائج المختبر',
  'med_findings': 'النتائج',
  'med_medications': 'الأدوية',
  'med_vaccinations': 'التطعيمات',
  'med_history': 'التاريخ الطبي',
  'med_allergies': 'الحساسية',

  // --- Anamnesis ---
  'anamnesis_title': 'السيرة المرضية',
  'anamnesis_start': 'بدء الاستبيان',
  'anamnesis_complete': 'إكمال الاستبيان',
  'anamnesis_symptoms': 'الأعراض',
  'anamnesis_duration': 'منذ متى تعاني من هذه الأعراض؟',
  'anamnesis_severity': 'ما مدى شدة الأعراض؟ (1-10)',

  // --- Practice Info ---
  'practice_info': 'معلومات العيادة',
  'practice_hours': 'ساعات العمل',
  'practice_address': 'العنوان',
  'practice_phone': 'الهاتف',
  'practice_emergency': 'الطوارئ: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'الخصوصية',
  'privacy_consent': 'أوافق على معالجة بياناتي',
  'privacy_data_export': 'تصدير بياناتي',
  'privacy_data_delete': 'حذف بياناتي',
  'privacy_consent_revoke': 'سحب الموافقة',

  // --- Errors ---
  'error_generic': 'حدث خطأ غير متوقع',
  'error_network': 'لا يوجد اتصال بالإنترنت',
  'error_auth': 'فشل المصادقة',
  'error_not_found': 'غير موجود',
  'error_server': 'خطأ في الخادم',
  'error_timeout': 'انتهت مهلة الطلب',

  // --- Time/Date ---
  'time_minutes': '{count} دقيقة',
  'time_hours': '{count} ساعة',
  'time_days': '{count} يوم',
  'time_today': 'اليوم',
  'time_tomorrow': 'غداً',
  'time_yesterday': 'أمس',

  // --- Misc ---
  'misc_search': 'بحث',
  'misc_filter': 'تصفية',
  'misc_sort': 'ترتيب',
  'misc_all': 'الكل',
  'misc_none': 'لا شيء',
  'misc_yes': 'نعم',
  'misc_no': 'لا',

  // --- Recall System ---
  'recall_title': 'تذكيرات الفحوصات الوقائية',
  'recall_checkup': 'فحص عام',
  'recall_vaccination': 'تذكير بالتطعيم',
  'recall_screening': 'فحص وقائي',
  'recall_due': 'مستحق في {date}',
  'recall_overdue': 'متأخر {days} يوم',

  // --- Symptom Checker ---
  'symptom_title': 'فحص الأعراض',
  'symptom_describe': 'صف أعراضك',
  'symptom_location': 'أين بالضبط؟',
  'symptom_start': 'منذ متى؟',
  'symptom_intensity': 'الشدة',
  'symptom_result_urgent': 'يرجى مراجعة الطبيب قريباً',
  'symptom_result_routine': 'حدد موعداً عادياً',
  'symptom_result_emergency': 'اتصل بالطوارئ (112)',
  'symptom_disclaimer': 'هذا ليس تشخيصاً طبياً. في حالة الشك، اتصل بطبيبك.',

  // --- Lab Results ---
  'lab_title': 'نتائج المختبر',
  'lab_date': 'تاريخ الفحص',
  'lab_normal': 'المعدل الطبيعي',
  'lab_value': 'قيمتك',
  'lab_status_normal': 'ضمن المعدل الطبيعي',
  'lab_status_high': 'مرتفع',
  'lab_status_low': 'منخفض',
  'lab_trend': 'الاتجاه',
  'lab_no_results': 'لا توجد نتائج مختبر',

  // --- Medication Plan ---
  'medication_title': 'خطة الأدوية',
  'medication_name': 'الدواء',
  'medication_dose': 'الجرعة',
  'medication_frequency': 'التكرار',
  'medication_morning': 'صباحاً',
  'medication_noon': 'ظهراً',
  'medication_evening': 'مساءً',
  'medication_night': 'ليلاً',
  'medication_notes': 'ملاحظات',
  'medication_refill': 'طلب إعادة الوصفة',

  // --- Vaccination Pass ---
  'vaccination_title': 'سجل التطعيمات',
  'vaccination_name': 'التطعيم',
  'vaccination_date': 'تاريخ التطعيم',
  'vaccination_next': 'الجرعة التالية',
  'vaccination_batch': 'رقم الدفعة',
  'vaccination_doctor': 'الطبيب المعطي',
  'vaccination_add': 'إضافة تطعيم',
  'vaccination_reminder': 'تفعيل التذكير',

  // --- Forms ---
  'form_title': 'النماذج',
  'form_fill': 'تعبئة النموذج',
  'form_submit': 'إرسال النموذج',
  'form_save_draft': 'حفظ كمسودة',
  'form_required_fields': 'الحقول المطلوبة مميزة بـ *',

  // --- Accessibility ---
  'a11y_increase_text': 'تكبير النص',
  'a11y_decrease_text': 'تصغير النص',
  'a11y_high_contrast': 'تباين عالي',
  'a11y_screen_reader': 'وضع قارئ الشاشة',
};
