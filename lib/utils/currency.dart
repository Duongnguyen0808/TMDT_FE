import 'package:intl/intl.dart';

// Tỷ giá quy đổi USD -> VND (có thể chỉnh nếu cần)
const double usdToVndRate = 24000.0;

String formatVND(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

double toVND(double usdAmount) => usdAmount * usdToVndRate;

String usdToVndText(double usdAmount) => formatVND(toVND(usdAmount));