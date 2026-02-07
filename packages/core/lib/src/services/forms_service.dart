import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/forms.dart';

/// Service for practice forms and submissions.
class FormsService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  FormsService(this._dio);

  /// Lists available forms.
  Future<List<PracticeForm>> listForms({
    FormCategory? category,
    bool? fillableOnline,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.forms,
      queryParameters: {
        if (category != null) 'category': formCategoryToJson(category),
        if (fillableOnline != null) 'fillable_online': fillableOnline,
      },
    );
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(PracticeForm.fromJson)
        .toList();
  }

  /// Lists form categories with counts.
  Future<List<FormCategoryInfo>> listCategories() async {
    final response = await _dio.get(ApiEndpoints.formCategories);
    final payload = response.data as Map<String, dynamic>;
    final items = payload['categories'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(FormCategoryInfo.fromJson)
        .toList();
  }

  /// Loads form details.
  Future<PracticeForm> getForm(String formId) async {
    final response = await _dio.get(ApiEndpoints.form(formId));
    return PracticeForm.fromJson(response.data as Map<String, dynamic>);
  }

  /// Requests a form download link.
  Future<FormDownloadInfo> downloadForm({
    required String formId,
    FormFormat format = FormFormat.pdf,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.formDownload(formId),
      queryParameters: {'format': formFormatToJson(format)},
    );
    return FormDownloadInfo.fromJson(response.data as Map<String, dynamic>);
  }

  /// Submits an online form payload.
  Future<FormSubmissionResponse> submitForm({
    required String formId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.formSubmit(formId),
      data: data,
    );
    return FormSubmissionResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
