import 'dart:convert';

import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChangePasswordController extends GetxController {
  final box = GetStorage();
  RxBool isLoading = false.obs;

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      final url = Uri.parse('$appBaseUrl/change-password');
      final token = box.read('token');

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      isLoading.value = false;
      if (res.statusCode == 200) {
        Get.snackbar('Thành công', 'Đổi mật khẩu thành công',
            colorText: Colors.white, backgroundColor: kPrimary);
        return true;
      } else {
        final msg = _extractMessage(res.body);
        Get.snackbar('Thất bại', msg,
            colorText: Colors.white, backgroundColor: kRed);
        return false;
      }
    } catch (e) {
      isLoading.value = false;
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
