import 'dart:async';

import 'package:appliances_flutter/config/translations.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:translator/translator.dart';

/// Automatically fills missing English translations by calling Google Translate.
/// Results are cached in GetStorage so each key is translated only once.
class AutoTranslationService {
  AutoTranslationService._();
  static final AutoTranslationService _instance = AutoTranslationService._();
  factory AutoTranslationService() => _instance;

  final GoogleTranslator _translator = GoogleTranslator();
  final GetStorage _box = GetStorage();
  final String _cachePrefix = 'auto_translation_en_';
  final String _dynamicCachePrefix = 'auto_translation_dynamic_';
  bool _bootstrapped = false;
  final Set<String> _translatingKeys = <String>{};
  final Map<String, Future<String>> _pendingDynamic =
      <String, Future<String>>{};
  final LanguageService _languageService = LanguageService();
  static final RegExp _vietCharRegex =
      RegExp(r'[ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯưĂăẠ-ỹ]');

  Future<void> ensureEnglishTranslations() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final Map<String, String>? viMap =
        translationData['vi']?.map((key, value) => MapEntry(key, value));
    if (viMap == null || viMap.isEmpty) return;

    translationData['en'] ??= <String, String>{};
    final Map<String, String> enMap = translationData['en']!;

    for (final entry in viMap.entries) {
      final String key = entry.key;
      final String viText = entry.value;
      final String? currentEn = enMap[key];

      if (!_needsTranslation(currentEn, viText)) {
        continue;
      }

      final String? cached = _box.read<String>('$_cachePrefix$key');
      if (cached != null && cached.trim().isNotEmpty) {
        enMap[key] = cached;
        continue;
      }

      try {
        final translation = await _translator.translate(
          viText,
          from: 'vi',
          to: 'en',
        );
        final text = translation.text.trim();
        if (text.isNotEmpty) {
          enMap[key] = text;
          await _box.write('$_cachePrefix$key', text);
        }
      } catch (_) {
        enMap[key] = currentEn ?? viText;
      }
    }
  }

  String registerAndTranslate(String key, String viText) {
    translationData['vi'] ??= <String, String>{};
    translationData['en'] ??= <String, String>{};
    final viMap = translationData['vi']!;
    final enMap = translationData['en']!;

    viMap[key] = viText;
    enMap[key] ??= viText;

    _scheduleTranslation(key, viText);
    return key;
  }

  void _scheduleTranslation(String key, String viText) {
    if (_translatingKeys.contains(key)) return;

    final cached = _box.read<String>('$_cachePrefix$key');
    if (cached != null && cached.trim().isNotEmpty) {
      translationData['en']?[key] = cached;
      return;
    }

    _translatingKeys.add(key);
    unawaited(
        _translator.translate(viText, from: 'vi', to: 'en').then((value) async {
      final text = value.text.trim();
      if (text.isNotEmpty) {
        translationData['en']?[key] = text;
        await _box.write('$_cachePrefix$key', text);
      }
    }).catchError((_) {
      translationData['en']?[key] ??= viText;
    }).whenComplete(() {
      _translatingKeys.remove(key);
    }));
  }

  String detectLanguage(String value) {
    if (_vietCharRegex.hasMatch(value)) {
      return 'vi';
    }
    return 'en';
  }

  Future<String> translateDynamic(
    String source, {
    String from = 'auto',
  }) async {
    final trimmed = source.trim();
    if (trimmed.isEmpty) return source;

    final target = _languageService.getCurrentLanguage();
    if (target.isEmpty) {
      return source;
    }

    String resolvedFrom = from;
    if (resolvedFrom == 'auto') {
      resolvedFrom = detectLanguage(trimmed);
    }

    if (target == resolvedFrom) {
      return source;
    }

    final cacheKey =
        '$_dynamicCachePrefix$resolvedFrom->$target-${trimmed.hashCode.toUnsigned(32)}';
    final cached = _box.read<String>(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final pending = _pendingDynamic[cacheKey];
    if (pending != null) {
      return pending;
    }

    final completer = Completer<String>();
    _pendingDynamic[cacheKey] = completer.future;

    try {
      final translation =
          await _translator.translate(trimmed, from: resolvedFrom, to: target);
      final translated = translation.text.trim();
      final resolved = translated.isNotEmpty ? translated : source;
      await _box.write(cacheKey, resolved);
      completer.complete(resolved);
      return resolved;
    } catch (_) {
      completer.complete(source);
      return source;
    } finally {
      _pendingDynamic.remove(cacheKey);
    }
  }

  bool _needsTranslation(String? currentEn, String viText) {
    if (currentEn == null || currentEn.trim().isEmpty) {
      return true;
    }
    return currentEn.trim() == viText.trim();
  }
}
