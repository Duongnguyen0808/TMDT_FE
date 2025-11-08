// ignore_for_file: prefer_final_fields
import 'dart:convert';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class VerificationController extends GetxController {
  final box = GetStorage();

  String _code = "";

  String get code => _code;

  set setCode(String value) {
    _code = value;
  }

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool value) {
    _isLoading.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    _checkUserStillExists();
  }

  Future<void> _checkUserStillExists() async {
    String? accessToken = box.read("token");
    if (accessToken == null) return;

    Uri url = Uri.parse('$appBaseUrl/api/users');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      var response = await http.get(url, headers: headers);
      // If user has been auto-deleted by TTL, backend now returns 404
      if (response.statusCode == 404 || response.statusCode == 401) {
        await box.erase();
        Get.snackbar(
          "Phiên xác minh đã hết hạn",
          "Tài khoản đã bị xoá do không xác minh trong 10 phút",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error_outline),
        );
        Get.offAll(() => const LoginRedirect());
      }
    } catch (e) {
      // silent fail – keep page if network error
    }
  }

  void verificationFunction() async {
    setLoading = true;
    String accessToken = box.read("token");

    Uri url = Uri.parse('$appBaseUrl/api/users/verify/$code');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        LoginResponse data = loginResponseFromJson(response.body);

        String userId = data.id;
        String userData = jsonEncode(data);

        box.write(userId, userData);
        box.write("token", data.userToken);
        box.write("userId", data.id);
        box.write("verification", data.verification);

        setLoading = false;

        Get.snackbar(
            "Bạn đã xác minh thành công", "Chúc bạn có trải nghiệm tuyệt vời",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(Ionicons.star_outline));

        Get.offAll(() => MainScreen());
      } else {
        var error = apiErrorFromJson(response.body);

        // If user no longer exists (TTL auto-delete), clear local session and go to login
        if (response.statusCode == 404 || error.message.contains("User not found")) {
          await box.erase();
          Get.snackbar(
            "Không xác minh được tài khoản",
            "Tài khoản đã bị xoá do không xác minh trong 10 phút",
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline),
          );
          Get.offAll(() => const LoginRedirect());
        } else {
          Get.snackbar("Không xác minh được tài khoản", error.message,
              colorText: kLightWhite,
              backgroundColor: kRed,
              icon: const Icon(Icons.error_outline));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
