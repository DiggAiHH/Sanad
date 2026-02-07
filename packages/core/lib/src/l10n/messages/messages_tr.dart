// =============================================================================
// TURKISH (tr_TR)
// =============================================================================

const Map<String, String> messages = {
  // --- Buttons ---
  'button_submit': 'Gönder',
  'button_cancel': 'İptal',
  'button_save': 'Kaydet',
  'button_delete': 'Sil',
  'button_edit': 'Düzenle',
  'button_back': 'Geri',
  'button_next': 'İleri',
  'button_close': 'Kapat',
  'button_confirm': 'Onayla',
  'button_retry': 'Tekrar Dene',
  'button_refresh': 'Yenile',
  'button_login': 'Giriş Yap',
  'button_logout': 'Çıkış Yap',
  'button_register': 'Kayıt Ol',

  // --- Navigation ---
  'nav_home': 'Ana Sayfa',
  'nav_settings': 'Ayarlar',
  'nav_profile': 'Profil',
  'nav_help': 'Yardım',

  // --- Status ---
  'status_loading': 'Yükleniyor...',
  'status_error': 'Bir hata oluştu',
  'status_success': 'Başarılı',
  'status_empty': 'Veri bulunamadı',
  'status_offline': 'Çevrimdışı',
  'status_online': 'Çevrimiçi',

  // --- Validation ---
  'validation_required': 'Bu alan zorunludur',
  'validation_email': 'Geçerli bir e-posta adresi girin',
  'validation_min_length': 'En az {min} karakter gerekli',
  'validation_max_length': 'En fazla {max} karakter',
  'validation_phone': 'Geçerli bir telefon numarası girin',

  // --- Auth ---
  'auth_email': 'E-posta Adresi',
  'auth_password': 'Şifre',
  'auth_forgot_password': 'Şifremi unuttum',
  'auth_login_title': 'Giriş Yap',
  'auth_register_title': 'Hesap Oluştur',
  'auth_welcome': 'Tekrar hoş geldiniz!',

  // --- Queue/Ticket ---
  'ticket_number': 'Sıra Numarası',
  'ticket_status': 'Durum',
  'ticket_status_waiting': 'Bekliyor',
  'ticket_status_called': 'Çağrıldı',
  'ticket_status_in_progress': 'İşlemde',
  'ticket_status_completed': 'Tamamlandı',
  'ticket_status_cancelled': 'İptal Edildi',
  'ticket_wait_time': 'Tahmini Bekleme Süresi',
  'ticket_position': 'Sıradaki Pozisyon',
  'queue_title': 'Sıra',
  'queue_empty': 'Sıra boş',

  // --- Appointments ---
  'appointment_title': 'Randevular',
  'appointment_book': 'Randevu Al',
  'appointment_cancel': 'Randevu İptal Et',
  'appointment_reschedule': 'Randevuyu Değiştir',
  'appointment_confirmed': 'Randevu Onaylandı',
  'appointment_date': 'Tarih',
  'appointment_time': 'Saat',
  'appointment_doctor': 'Doktor',
  'appointment_reason': 'Ziyaret Nedeni',
  'appointment_no_upcoming': 'Yaklaşan randevu yok',

  // --- Documents ---
  'doc_request_title': 'Belge Talepleri',
  'doc_prescription': 'Reçete',
  'doc_sick_note': 'Hastalık Raporu',
  'doc_referral': 'Sevk',
  'doc_certificate': 'Belge',
  'doc_status_pending': 'Beklemede',
  'doc_status_ready': 'Hazır',
  'doc_status_rejected': 'Reddedildi',

  // --- Consultation ---
  'consultation_title': 'Danışma',
  'consultation_video': 'Video Görüşme',
  'consultation_phone': 'Telefon Görüşmesi',
  'consultation_chat': 'Sohbet',
  'consultation_callback': 'Geri Arama Talep Et',
  'consultation_start': 'Görüşmeyi Başlat',
  'consultation_end': 'Görüşmeyi Bitir',
  'consultation_waiting': 'Doktor bekleniyor...',

  // --- Medical Data ---
  'med_lab_results': 'Laboratuvar Sonuçları',
  'med_findings': 'Bulgular',
  'med_medications': 'İlaçlar',
  'med_vaccinations': 'Aşılar',
  'med_history': 'Tıbbi Geçmiş',
  'med_allergies': 'Alerjiler',

  // --- Anamnesis ---
  'anamnesis_title': 'Anamnez',
  'anamnesis_start': 'Anketi Başlat',
  'anamnesis_complete': 'Anketi Tamamla',
  'anamnesis_symptoms': 'Belirtiler',
  'anamnesis_duration': 'Şikayetleriniz ne zamandan beri var?',
  'anamnesis_severity': 'Şikayetleriniz ne kadar şiddetli? (1-10)',

  // --- Practice Info ---
  'practice_info': 'Klinik Bilgileri',
  'practice_hours': 'Çalışma Saatleri',
  'practice_address': 'Adres',
  'practice_phone': 'Telefon',
  'practice_emergency': 'Acil: 112',

  // --- Privacy/DSGVO ---
  'privacy_title': 'Gizlilik',
  'privacy_consent': 'Verilerimin işlenmesine onay veriyorum',
  'privacy_data_export': 'Verilerimi dışa aktar',
  'privacy_data_delete': 'Verilerimi sil',
  'privacy_consent_revoke': 'Onayı geri çek',

  // --- Errors ---
  'error_generic': 'Beklenmeyen bir hata oluştu',
  'error_network': 'İnternet bağlantısı yok',
  'error_auth': 'Kimlik doğrulama başarısız',
  'error_not_found': 'Bulunamadı',
  'error_server': 'Sunucu hatası',
  'error_timeout': 'Zaman aşımı',

  // --- Time/Date ---
  'time_minutes': '{count} dakika',
  'time_hours': '{count} saat',
  'time_days': '{count} gün',
  'time_today': 'Bugün',
  'time_tomorrow': 'Yarın',
  'time_yesterday': 'Dün',

  // --- Misc ---
  'misc_search': 'Ara',
  'misc_filter': 'Filtrele',
  'misc_sort': 'Sırala',
  'misc_all': 'Tümü',
  'misc_none': 'Hiçbiri',
  'misc_yes': 'Evet',
  'misc_no': 'Hayır',

  // --- Recall System ---
  'recall_title': 'Kontrol Hatırlatmaları',
  'recall_checkup': 'Genel Muayene',
  'recall_vaccination': 'Aşı Hatırlatması',
  'recall_screening': 'Tarama',
  'recall_due': '{date} tarihinde',
  'recall_overdue': '{days} gün gecikmiş',

  // --- Symptom Checker ---
  'symptom_title': 'Semptom Kontrolü',
  'symptom_describe': 'Belirtilerinizi tanımlayın',
  'symptom_location': 'Tam olarak nerede?',
  'symptom_start': 'Ne zamandan beri?',
  'symptom_intensity': 'Şiddet',
  'symptom_result_urgent': 'Lütfen en kısa sürede doktora başvurun',
  'symptom_result_routine': 'Normal randevu alın',
  'symptom_result_emergency': 'Acil servisi arayın (112)',
  'symptom_disclaimer':
      'Bu tıbbi bir tanı değildir. Şüphe durumunda doktorunuza başvurun.',

  // --- Lab Results ---
  'lab_title': 'Laboratuvar Değerleri',
  'lab_date': 'Test Tarihi',
  'lab_normal': 'Normal Aralık',
  'lab_value': 'Değeriniz',
  'lab_status_normal': 'Normal Aralıkta',
  'lab_status_high': 'Yüksek',
  'lab_status_low': 'Düşük',
  'lab_trend': 'Eğilim',
  'lab_no_results': 'Laboratuvar sonucu yok',

  // --- Medication Plan ---
  'medication_title': 'İlaç Planı',
  'medication_name': 'İlaç',
  'medication_dose': 'Doz',
  'medication_frequency': 'Sıklık',
  'medication_morning': 'Sabah',
  'medication_noon': 'Öğle',
  'medication_evening': 'Akşam',
  'medication_night': 'Gece',
  'medication_notes': 'Notlar',
  'medication_refill': 'Yeniden Reçete Talep Et',

  // --- Vaccination Pass ---
  'vaccination_title': 'Aşı Kartı',
  'vaccination_name': 'Aşı',
  'vaccination_date': 'Aşı Tarihi',
  'vaccination_next': 'Sonraki Hatırlatma',
  'vaccination_batch': 'Parti Numarası',
  'vaccination_doctor': 'Aşılayan Doktor',
  'vaccination_add': 'Aşı Ekle',
  'vaccination_reminder': 'Hatırlatmayı Etkinleştir',

  // --- Forms ---
  'form_title': 'Formlar',
  'form_fill': 'Form Doldur',
  'form_submit': 'Formu Gönder',
  'form_save_draft': 'Taslak Kaydet',
  'form_required_fields': 'Zorunlu alanlar * ile işaretlenmiştir',

  // --- Accessibility ---
  'a11y_increase_text': 'Yazı Boyutunu Artır',
  'a11y_decrease_text': 'Yazı Boyutunu Azalt',
  'a11y_high_contrast': 'Yüksek Kontrast',
  'a11y_screen_reader': 'Ekran Okuyucu Modu',
};
