import 'package:appliances_flutter/services/auto_translation_service.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:flutter/material.dart';

class ReusableText extends StatelessWidget {
  const ReusableText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.autoTranslate,
    this.fromLanguage = 'auto',
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final bool? autoTranslate;
  final String fromLanguage;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final translationService = AutoTranslationService();
    final resolvedFrom = _resolveSourceLanguage(text, translationService);
    final shouldTranslate = _shouldTranslate(text, resolvedFrom);
    if (!shouldTranslate) {
      return _buildText(text);
    }

    return FutureBuilder<String>(
      future: translationService.translateDynamic(text, from: resolvedFrom),
      builder: (context, snapshot) {
        final translated = snapshot.data;
        if (translated == null) {
          return _buildText(text);
        }
        return _buildText(translated);
      },
    );
  }

  bool _shouldTranslate(String value, String resolvedFrom) {
    if (value.trim().isEmpty) return false;

    final locale = LanguageService().getCurrentLanguage();
    if (locale.isEmpty || locale == resolvedFrom) return false;

    if (autoTranslate != null) {
      return autoTranslate!;
    }

    return true;
  }

  String _resolveSourceLanguage(
      String value, AutoTranslationService translationService) {
    if (fromLanguage.toLowerCase() == 'auto') {
      return translationService.detectLanguage(value);
    }
    return fromLanguage;
  }

  Widget _buildText(String value) {
    return Text(
      value,
      maxLines: maxLines ?? 1,
      style: style,
      softWrap: softWrap ?? true,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}
