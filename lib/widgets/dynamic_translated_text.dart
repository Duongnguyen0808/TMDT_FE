import 'package:appliances_flutter/services/auto_translation_service.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:flutter/material.dart';

class DynamicTranslatedText extends StatelessWidget {
  const DynamicTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fromLanguage = 'auto',
    this.placeholder,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String fromLanguage;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final translationService = AutoTranslationService();
    final language = LanguageService().getCurrentLanguage();
    final resolvedFrom = _resolveSourceLanguage(translationService);
    if (language == resolvedFrom || text.trim().isEmpty || language.isEmpty) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return FutureBuilder<String>(
      future: translationService.translateDynamic(text, from: resolvedFrom),
      builder: (context, snapshot) {
        final display = snapshot.data;
        if (display == null) {
          return placeholder ??
              Text(
                text,
                style: style,
                textAlign: textAlign,
                maxLines: maxLines,
                overflow: overflow,
              );
        }
        return Text(
          display,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  String _resolveSourceLanguage(AutoTranslationService translationService) {
    if (fromLanguage.toLowerCase() == 'auto') {
      return translationService.detectLanguage(text);
    }
    return fromLanguage;
  }
}
