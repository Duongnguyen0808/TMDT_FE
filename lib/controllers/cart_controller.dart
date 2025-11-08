import 'dart:convert';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController {
  final box = GetStorage();
  RxBool _isLoading = false.obs;

  // Đếm số sản phẩm trong giỏ
  final RxInt _cartCount = 0.obs;

  int get cartCount => _cartCount.value;
  void setCartCount(int value) {
    _cartCount.value = value;
  }

  bool get isLoading => _isLoading.value;

  set setLoading(bool value) {
    _isLoading.value = value;
  }

  void addToCart(String cart) async {
    setLoading = true;

    String accessToken = box.read("token");

    var url = Uri.parse("$appBaseUrl/api/cart");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      final response = await http.post(url, headers: headers, body: cart);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Bắt cartCount từ backend
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final count = (json['cartCount'] ?? json['count']) ?? 0;
          setCartCount(int.tryParse(count.toString()) ?? 0);
        } catch (_) {}

        Get.snackbar("Đã thêm vào giỏ", "Chúc bạn có trải nghiệm tuyệt vời",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(
              Icons.check_circle_outline,
              color: kLightWhite,
            ));
      } else {
        final error = apiErrorFromJson(response.body);
        Get.snackbar("Lỗi", error.message,
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(
              Icons.error_outline,
              color: kLightWhite,
            ));
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading = false;
    }
  }

  void removeFrom(String productId, Function refetch) async {
    setLoading = true;

    String accessToken = box.read("token");

    var url = Uri.parse("$appBaseUrl/api/cart/$productId");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        setLoading = false;
        // Bắt cartCount từ phản hồi xoá
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final count = (json['cartCount'] ?? json['count']) ?? 0;
          setCartCount(int.tryParse(count.toString()) ?? 0);
        } catch (_) {}

        refetch();
        Get.snackbar("Đã xoá khỏi giỏ", "Chúc bạn có trải nghiệm tuyệt vời",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(
              Icons.check_circle_outline,
              color: kLightWhite,
            ));
      } else {
        final error = apiErrorFromJson(response.body);
        Get.snackbar("Lỗi", error.message,
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(
              Icons.error_outline,
              color: kLightWhite,
            ));
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading = false;
    }
  }

  // Lấy số lượng giỏ hàng khi khởi tạo app
  Future<void> fetchCartCount() async {
    final accessToken = box.read("token");
    if (accessToken == null) return;

    final url = Uri.parse("$appBaseUrl/api/cart/count");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    try {
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final count = (json['count'] ?? json['cartCount']) ?? 0;
        setCartCount(int.tryParse(count.toString()) ?? 0);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchCartCount();
  }
}
