import 'package:appliances_flutter/services/language_service.dart';

class ApiHelper {
  static final LanguageService _languageService = LanguageService();

  /// Add language parameter to URL
  static String addLanguageParam(String url) {
    final lang = _languageService.getCurrentLanguage();

    // Check if URL already has query parameters
    if (url.contains('?')) {
      return '$url&lang=$lang';
    } else {
      return '$url?lang=$lang';
    }
  }

  /// Get headers with language preference
  static Map<String, String> getHeaders(
      {Map<String, String>? additionalHeaders}) {
    final headers = {
      'Accept-Language': _languageService.getCurrentLanguage(),
      'Content-Type': 'application/json',
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Build URL with base and language parameter
  static String buildUrl(String baseUrl, String endpoint,
      {Map<String, String>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');

    final params = queryParams ?? {};
    params['lang'] = _languageService.getCurrentLanguage();

    return uri.replace(queryParameters: params).toString();
  }
}
