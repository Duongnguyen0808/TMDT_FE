import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.labelKey,
    required this.descriptionKey,
    required this.symbol,
    required this.locale,
    required this.vndRate,
    required this.decimalDigits,
  });

  final String code;
  final String labelKey;
  final String descriptionKey;
  final String symbol;
  final String locale;
  final double vndRate;
  final int decimalDigits;
}

class CurrencyService {
  CurrencyService._internal();
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;

  static const String vnd = 'VND';
  static const String usd = 'USD';

  final GetStorage _box = GetStorage();
  final String _currencyKey = 'app_currency';

  final Map<String, CurrencyOption> _options = {
    vnd: const CurrencyOption(
      code: vnd,
      labelKey: 'currency_vnd',
      descriptionKey: 'currency_vnd_hint',
      symbol: '₫',
      locale: 'vi_VN',
      vndRate: 1,
      decimalDigits: 0,
    ),
    usd: const CurrencyOption(
      code: usd,
      labelKey: 'currency_usd',
      descriptionKey: 'currency_usd_hint',
      symbol: '\$',
      locale: 'en_US',
      vndRate: 24000,
      decimalDigits: 2,
    ),
  };

  List<CurrencyOption> get supportedCurrencies =>
      List.unmodifiable(_options.values);

  String getCurrentCurrency() => _normalizeCurrency(_box.read(_currencyKey));

  Future<void> setCurrency(String code) async {
    await _box.write(_currencyKey, _normalizeCurrency(code));
  }

  String format(num amountInVnd) {
    final CurrencyOption option = _options[getCurrentCurrency()]!;
    final double converted = amountInVnd / option.vndRate;
    final formatter = NumberFormat.currency(
      locale: option.locale,
      symbol: option.symbol,
      decimalDigits: option.decimalDigits,
    );
    return formatter.format(converted);
  }

  double convert(num amountInVnd) {
    final CurrencyOption option = _options[getCurrentCurrency()]!;
    return amountInVnd / option.vndRate;
  }

  String getCurrencyDisplayName([String? code]) {
    final CurrencyOption option = _options[_normalizeCurrency(code)]!;
    return option.labelKey.tr;
  }

  String getCurrencyDescription([String? code]) {
    final CurrencyOption option = _options[_normalizeCurrency(code)]!;
    return option.descriptionKey.tr;
  }

  CurrencyOption getOption(String code) => _options[_normalizeCurrency(code)]!;

  String _normalizeCurrency(String? code) {
    if (code != null && _options.containsKey(code)) {
      return code;
    }
    return vnd;
  }
}
