import 'package:appliances_flutter/services/auto_translation_service.dart';
import 'package:get/get.dart';

extension AutoTranslationExtension on String {
  /// Registers this Vietnamese string under [key] (or itself) and returns the translated value.
  String trAuto({String? key}) {
    final translationKey = AutoTranslationService().registerAndTranslate(
      key ?? this,
      this,
    );
    return translationKey.tr;
  }
}
