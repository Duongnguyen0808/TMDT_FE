// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/auth/verification_page.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newState) {
    _isLoading.value = newState;
  }

  void loginFunction(String data) async {
    setLoading = true;

    Uri url = Uri.parse('$appBaseUrl/login');

    Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      // Augment payload with fcmToken if available
      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        payload = {};
      }
      // Prefer token cached in storage by _initMessaging
      String? fcm = box.read('fcm');
      // If not present, try to fetch quickly
      if ((fcm == null || fcm.isEmpty)) {
        try {
          fcm = await FirebaseMessaging.instance.getToken();
        } catch (_) {}
      }
      if (fcm != null && fcm.isNotEmpty) {
        payload['fcmToken'] = fcm;
      }

      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload.isEmpty ? jsonDecode(data) : payload),
      );

      if (response.statusCode == 200) {
        LoginResponse data = loginResponseFromJson(response.body);

        String userId = data.id;
        String userData = jsonEncode(data);

        box.write(userId, userData);
        box.write("token", data.userToken);
        box.write("userId", data.id);
        box.write("verification", data.verification);

        setLoading = false;

        Get.snackbar("Đăng nhập thành công", "Chào mừng bạn quay trở lại",
            colorText: kLightWhite, backgroundColor: kPrimary);

        // Đồng bộ giỏ khách lên server sau khi đăng nhập
        try {
          final cartController = Get.put(CartController());
          await cartController.mergeGuestCartToServer();
        } catch (_) {}

        // Gửi FCM token lên server ngay sau đăng nhập (đảm bảo đồng bộ)
        try {
          final token = box.read('token');
          final fcmToken = box.read('fcm');
          if (token is String &&
              token.isNotEmpty &&
              fcmToken is String &&
              fcmToken.isNotEmpty) {
            final urlFcm = Uri.parse('$appBaseUrl/api/users/fcm-token');
            await http.post(
              urlFcm,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token,
              },
              body: jsonEncode({'fcmToken': fcmToken}),
            );
          }
        } catch (_) {}

        // Xử lý yêu cầu thêm giỏ hàng còn pending (người dùng bấm thêm khi chưa đăng nhập)
        try {
          final String? pending = box.read('pendingCartAdd');
          if (pending != null && pending.isNotEmpty) {
            final cartController = Get.put(CartController());
            cartController.addToCart(pending);
            box.remove('pendingCartAdd');
          }
        } catch (_) {}

        if (data.verification == false) {
          Get.offAll(() => const VerificationPage(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 900));
        }

        if (data.verification == true) {
          Get.offAll(() => MainScreen(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 900));
        }
      } else {
        // Non-200: show error and reset loading
        try {
          var error = apiErrorFromJson(response.body);
          Get.snackbar("Đăng nhập thất bại", error.message,
              colorText: kLightWhite, backgroundColor: kRed);
        } catch (_) {
          Get.snackbar("Đăng nhập thất bại",
              "Máy chủ hiện không phản hồi. Vui lòng thử lại.",
              colorText: kLightWhite, backgroundColor: kRed);
        }
        setLoading = false;
      }
    } catch (e) {
      // Network/parse error: show error and reset loading
      setLoading = false;
      Get.snackbar("Đăng nhập thất bại", e.toString(),
          colorText: kLightWhite, backgroundColor: kRed);
      debugPrint(e.toString());
    }
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Firebase signOut error: $e');
    }

    await box.erase();
    Get.offAll(() => MainScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 900));
  }

  LoginResponse? getUserInfo() {
    String? userId = box.read("userId");
    String? data;
    if (userId != null) {
      data = box.read(userId.toString());
    }

    if (data != null) {
      return loginResponseFromJson(data);
    }
    return null;
  }
}
