import 'package:appliances_flutter/services/currency_service.dart';

final CurrencyService _currencyService = CurrencyService();

String formatVND(num amount) => _currencyService.format(amount);

// Giữ nguyên chữ ký hàm cũ để hạn chế phải sửa nhiều nơi trong codebase.
String usdToVndText(double amount) => _currencyService.format(amount);

double convertToSelectedCurrency(num amount) =>
    _currencyService.convert(amount);

String currentCurrencyCode() => _currencyService.getCurrentCurrency();
