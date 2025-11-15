import 'dart:convert';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/cart_request.dart';
import 'package:appliances_flutter/utils/guest_cart.dart';
import 'package:appliances_flutter/controllers/tab_index_controller.dart';
import 'package:flutter/material.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';

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
    // Ghi xuống storage để các trang có thể lắng nghe và refetch
    try {
      box.write('cartCount', value);
    } catch (_) {}
  }

  bool get isLoading => _isLoading.value;

  set setLoading(bool value) {
    _isLoading.value = value;
  }

  void addToCart(String cart) async {
    setLoading = true;
    try {
      final String? accessToken = box.read("token");

      // Guest cart flow when not logged in
      if (accessToken == null || accessToken.isEmpty) {
        // Require login: store pending request and redirect to login
        try {
          box.write('pendingCartAdd', cart);
        } catch (_) {}

        Get.to(() => const LoginRedirect(),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 700));

        Get.snackbar('Vui lòng đăng nhập',
            'Bạn cần đăng nhập để thêm sản phẩm vào giỏ hàng',
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline));

        setLoading = false;
        return;
      }

      // Logged-in flow: call backend cart API
      var url = Uri.parse("$appBaseUrl/api/cart");
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final response = await http.post(url, headers: headers, body: cart);
      if (response.statusCode == 200 || response.statusCode == 201) {
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
        // Chuyển sang tab Giỏ để hiển thị ngay và kích hoạt refetch
        try {
          box.write('tabIndex', 2);
          // Nếu TabIndexController đã được khởi tạo, cập nhật luôn.
          final tabController = Get.isRegistered<TabIndexController>()
              ? Get.find<TabIndexController>()
              : null;
          tabController?.setTabIndex = 2;
        } catch (_) {}
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

  // Tăng số lượng của một item trong giỏ (đã đăng nhập)
  // Gửi lại POST /api/cart với quantity=1 và unitPrice
  Future<void> incrementItem(
      {required String productId,
      required List<String> additives,
      required double unitPrice,
      required Function refetch}) async {
    setLoading = true;
    try {
      final String? accessToken = box.read("token");
      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Vui lòng đăng nhập', 'Bạn cần đăng nhập để chỉnh số lượng',
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline));
        return;
      }

      final url = Uri.parse("$appBaseUrl/api/cart");
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      final body = cartRequestToJson(CartRequest(
          productId: productId,
          additives: additives,
          quantity: 1,
          totalPrice: unitPrice));
      final res = await http.post(url, headers: headers, body: body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        try {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          final count = (json['cartCount'] ?? json['count']) ?? 0;
          setCartCount(int.tryParse(count.toString()) ?? 0);
        } catch (_) {}
        refetch();
      }
    } catch (e) {
      debugPrint('incrementItem error: ' + e.toString());
    } finally {
      setLoading = false;
    }
  }

  // Giảm số lượng của item; nếu về 0 thì xoá
  Future<void> decrementItem(
      {required String cartItemId, required Function refetch}) async {
    setLoading = true;
    try {
      final String? accessToken = box.read("token");
      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar('Vui lòng đăng nhập', 'Bạn cần đăng nhập để chỉnh số lượng',
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline));
        return;
      }

      final url = Uri.parse("$appBaseUrl/api/cart/decrement/$cartItemId");
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200 || res.statusCode == 400) {
        // API không trả cartCount, fetch lại
        await fetchCartCount();
        refetch();
      }
    } catch (e) {
      debugPrint('decrementItem error: ' + e.toString());
    } finally {
      setLoading = false;
    }
  }

  void removeFrom(String productId, Function refetch) async {
    setLoading = true;
    try {
      final String? accessToken = box.read("token");

      // Guest cart removal
      if (accessToken == null || accessToken.isEmpty) {
        final list = readGuestCart(box);
        list.removeWhere((e) => (e["_id"]?.toString() ?? "") == productId);
        writeGuestCart(box, list);
        setCartCount(list.length);
        refetch();
        Get.snackbar("Đã xoá khỏi giỏ", "Chúc bạn có trải nghiệm tuyệt vời",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(
              Icons.check_circle_outline,
              color: kLightWhite,
            ));
        return;
      }

      var url = Uri.parse("$appBaseUrl/api/cart/$productId");
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200) {
        setLoading = false;
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
    final String? accessToken = box.read("token");
    if (accessToken == null || accessToken.isEmpty) {
      // Initialize badge from guest storage
      setCartCount(guestCartCount(box));
      return;
    }

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

  /// Sau khi người dùng đăng nhập, đồng bộ giỏ hàng khách (lưu local)
  /// lên giỏ hàng tài khoản trên server, rồi xoá giỏ khách.
  Future<void> mergeGuestCartToServer() async {
    try {
      final String? accessToken = box.read("token");
      if (accessToken == null || accessToken.isEmpty) return;

      final List<Map<String, dynamic>> guest = readGuestCart(box);
      if (guest.isEmpty) return;

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final url = Uri.parse("$appBaseUrl/api/cart");

      for (final item in guest) {
        try {
          final productJson = Map<String, dynamic>.from(item['productId'] ?? {});
          final String productId = (productJson['_id'] ?? productJson['id'] ?? item['productId']).toString();
          final List<String> additives = List<String>.from((item['additives'] ?? []).map((e) => e.toString()));
          final int quantity = int.tryParse(item['quantity'].toString()) ?? 1;
          final double totalPrice = double.tryParse(item['totalPrice'].toString()) ?? 0.0;

          // Tính đơn giá từ tổng giá/quantity để server cộng dồn chính xác
          final double unitPrice = quantity > 0 ? (totalPrice / quantity) : totalPrice;

          // Gửi N lần với quantity = 1 để đảm bảo totalPrice tăng đúng
          for (int i = 0; i < quantity; i++) {
            final req = CartRequest(
              productId: productId,
              additives: additives,
              quantity: 1,
              totalPrice: unitPrice,
            );
            final body = cartRequestToJson(req);
            await http.post(url, headers: headers, body: body);
          }
        } catch (e) {
          debugPrint('mergeGuestCart item error: ' + e.toString());
        }
      }

      // Xoá giỏ khách sau khi đồng bộ
      writeGuestCart(box, []);
      // Cập nhật lại badge đếm từ server
      await fetchCartCount();
      Get.snackbar('Đã đồng bộ giỏ hàng', 'Giỏ hàng của bạn đã được lưu vào tài khoản',
          colorText: kLightWhite,
          backgroundColor: kPrimary,
          icon: const Icon(Icons.check_circle_outline));
    } catch (e) {
      debugPrint('mergeGuestCartToServer error: ' + e.toString());
    }
  }
}
