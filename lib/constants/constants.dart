import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String googleApiKey = '';

const kPrimary = Color(0xFF30b9b2);
const kPrimaryLight = Color(0xFF40F3EA);
const kSecondary = Color(0xffffa44f);
const kSecondaryLight = Color(0xFFffe5db);
const kTertiary = Color(0xff0078a6);
const kGray = Color(0xff83829A);
const kGrayLight = Color(0xffC1C0C8);
const kLightWhite = Color(0xffFAFAFC);
const kWhite = Color(0xfffFFFFF);
const kDark = Color(0xff000000);
const kRed = Color(0xffe81e4d);
const kOffWhite = Color(0xffF3F4F8);

double height = 825.h;
double width = 375.w;

// Base URL tuỳ môi trường: Web dùng localhost, Android emulator dùng IP mạng LAN
// Sử dụng đúng PORT từ backend (.env: PORT=6013)
// final String appBaseUrl =
//     kIsWeb ? "http://localhost:6013" : "http://192.168.1.5:6013";

// Deprecated: kBaseUrl (giữ lại nếu nơi khác tham chiếu)
// Note: Avoid auto-detect base URL; use a single LAN URL for real devices
const String appBaseUrl =
    "http://192.168.1.5:6013"; // Sử dụng 1 URL LAN cố định cho thiết bị thật. Hãy đổi IP này cho đúng mạng của bạn.

// MapBox API Key (you need to replace this with your actual MapBox API key)
const String kMapBoxApiKey =
    "pk.eyJ1IjoiZXhhbXBsZSIsImEiOiJjbGV4YW1wbGUifQ.example_token_here";

final List<String> verificationReasons = [
  'Cập nhật theo thời gian thực: Nhận thông báo ngay lập tức về trạng thái đơn hàng của bạn.',
  'Giao tiếp trực tiếp: Số điện thoại đã được xác minh đảm bảo giao tiếp liền mạch.',
  'Bảo mật nâng cao: Bảo vệ tài khoản của bạn và xác nhận đơn hàng một cách an toàn.',
  'Ưu đãi độc quyền: Cập nhật thông tin về các ưu đãi và chương trình khuyến mãi đặc biệt.'
];

// Danh sách tab trạng thái đơn hàng (3 trạng thái chính)
const List<String> orderList = [
  'Chờ xử lý',
  'Đang chuẩn bị',
  'Đã giao',
];
List<String> reasonsToAddAddress = [
  "Đảm bảo đơn hàng được giao chính xác tới vị trí của bạn.",
  "Cho phép kiểm tra dịch vụ giao hàng có sẵn trong khu vực.",
  "Trải nghiệm cá nhân hoá: hiển thị cửa hàng gần bạn, thời gian dự kiến và ưu đãi.",
  "Tối ưu thanh toán: lưu địa chỉ để đặt hàng nhanh hơn.",
  "Quản lý nhiều địa chỉ (nhà, công ty) để chuyển đổi thuận tiện.",
];
