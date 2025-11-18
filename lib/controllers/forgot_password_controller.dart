import 'dart:convert';

import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordController extends GetxController {
  RxBool isSending = false.obs;
  RxBool isResetting = false.obs;
  RxString email = ''.obs;

  Future<bool> sendOtp(String emailValue) async {
    try {
      isSending.value = true;
      final url = Uri.parse('$appBaseUrl/forgot-password');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailValue,
        }),
      );
      isSending.value = false;
      if (res.statusCode == 200) {
        Get.snackbar('Thành công', 'Đã gửi OTP đến email',
            colorText: Colors.white, backgroundColor: kPrimary);
        email.value = emailValue;
        return true;
      } else {
        final msg = _extractMessage(res.body);
        Get.snackbar('Thất bại', msg,
            colorText: Colors.white, backgroundColor: kRed);
        return false;
      }
    } catch (e) {
      isSending.value = false;
      Get.snackbar('Lỗi', e.toString(),
          colorText: Colors.white, backgroundColor: kRed);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    try {
      isResetting.value = true;
      final url = Uri.parse('$appBaseUrl/reset-password');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.value,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      isResetting.value = false;
      if (res.statusCode == 200) {
        Get.snackbar('Thành công', 'Đặt lại mật khẩu thành công',
            colorText: Colors.white, backgroundColor: kPrimary);
        return true;
      } else {
        final msg = _extractMessage(res.body);
        Get.snackbar('Thất bại', msg,
            colorText: Colors.white, backgroundColor: kRed);
        return false;
      }
    } catch (e) {
      isResetting.value = false;
      Get.snackbar('Lỗi', e.toString(),
          colorText: Colors.white, backgroundColor: kRed);
      return false;
    }
  }

  String _extractMessage(String body) {
    try {
      final json = jsonDecode(body);
      return json['message']?.toString() ?? 'Có lỗi xảy ra';
    } catch (_) {
      return 'Có lỗi xảy ra';
    }
  }
}
