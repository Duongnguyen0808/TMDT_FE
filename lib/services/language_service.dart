import 'package:get_storage/get_storage.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final box = GetStorage();
  final String _languageKey = 'app_language';

  // Supported languages
  static const String vietnamese = 'vi';
  static const String english = 'en';

  /// Get current language (default: Vietnamese)
  String getCurrentLanguage() {
    return box.read(_languageKey) ?? vietnamese;
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    await box.write(_languageKey, languageCode);
  }

  /// Check if current language is Vietnamese
  bool isVietnamese() {
    return getCurrentLanguage() == vietnamese;
  }

  /// Check if current language is English
  bool isEnglish() {
    return getCurrentLanguage() == english;
  }

  /// Get language parameter for API calls
  String getLanguageParam() {
    return 'lang=${getCurrentLanguage()}';
  }

  /// Get language display name
  String getLanguageDisplayName() {
    switch (getCurrentLanguage()) {
      case english:
        return 'English';
      case vietnamese:
      default:
        return 'Tiếng Việt';
    }
  }
}
