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

const String appBaseUrl = "http://10.0.2.2:6013";
// const String appBaseUrl = "http://192.168.1.5:6013"; // Device thật

final List<String> verificationReasons = [
  'Cập nhật theo thời gian thực: Nhận thông báo ngay lập tức về trạng thái đơn hàng của bạn.',
  'Giao tiếp trực tiếp: Số điện thoại đã được xác minh đảm bảo giao tiếp liền mạch.',
  'Bảo mật nâng cao: Bảo vệ tài khoản của bạn và xác nhận đơn hàng một cách an toàn.',
  'Ưu đãi độc quyền: Cập nhật thông tin về các ưu đãi và chương trình khuyến mãi đặc biệt.'
];
