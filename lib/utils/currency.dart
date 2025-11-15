import 'package:intl/intl.dart';

// Hiển thị tiền tệ theo chuẩn Việt Nam (VND) mà không quy đổi.
// Lưu ý: mọi con số trong hệ thống được hiểu là VND trực tiếp.
String formatVND(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

// Giữ nguyên tên hàm để hạn chế phải sửa nhiều nơi trong codebase.
// Bây giờ chỉ định dạng VND, không còn chuyển đổi từ USD -> VND.
String usdToVndText(double amount) => formatVND(amount);
