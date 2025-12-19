// ignore_for_file: unused_element

import 'dart:convert';

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/order_request.dart';
import 'package:appliances_flutter/models/order_response.dart';
import 'package:appliances_flutter/models/payment-request.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrdersController extends GetxController {
  final box = GetStorage();
  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newState) {
    _isLoading.value = newState;
  }

  RxString _paymentUrl = ''.obs;

  String get paymentUrl => _paymentUrl.value;

  set setPaymentUrl(String mewState) {
    _paymentUrl.value = mewState;
  }

  RxString orderId = ''.obs;
  String get getOrderId => orderId.value;

  set setOrderId(String newState) {
    orderId.value = newState;
  }

  OrderRequest? order;

  // Lưu phương thức thanh toán đã chọn để hiển thị ở trang Successful
  RxString _selectedMethod = ''.obs;
  String get selectedMethod => _selectedMethod.value;
  set setSelectedMethod(String m) => _selectedMethod.value = m;

  // Thông tin COD để hiển thị trang xác nhận
  RxString _codProductTitle = ''.obs;
  RxString _codAddressLine = ''.obs;
  RxDouble _codTotalPrice = 0.0.obs;
  RxInt _codQuantity = 1.obs;

  String get codProductTitle => _codProductTitle.value;
  String get codAddressLine => _codAddressLine.value;
  double get codTotalPrice => _codTotalPrice.value;
  int get codQuantity => _codQuantity.value;

  void setCodInfo({
    required String productTitle,
    required String addressLine,
    required double totalPrice,
    int quantity = 1,
  }) {
    _codProductTitle.value = productTitle;
    _codAddressLine.value = addressLine;
    _codTotalPrice.value = totalPrice;
    _codQuantity.value = quantity;
  }

  RxBool _iconChanger = false.obs;

  bool get iconChanger => _iconChanger.value;

  set setIcon(bool newState) {
    _iconChanger.value = newState;
  }

  void createOrder(String data, OrderRequest item,
      {String method = 'VNPay'}) async {
    final box = GetStorage();
    String accessToken = box.read("token");

    Uri url = Uri.parse('$appBaseUrl/api/orders');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      var response = await http.post(url, headers: headers, body: data);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 201) {
        OrderResponse orderResponse = orderResponseFromJson(response.body);

        // Use returned orderId from backend
        setOrderId = orderResponse.orderId;

        // Clear cart badge immediately so bottom nav reflects empty cart
        try {
          final cartController = Get.isRegistered<CartController>()
              ? Get.find<CartController>()
              : null;
          cartController?.setCartCount(0);
          await cartController?.fetchCartCount();
        } catch (_) {}

        // Lưu order để dùng ở màn hình Successful
        order = item;
        setSelectedMethod = method;

        // Khởi tạo thanh toán VNPay (chỉ hiển thị thành công sau khi VNPay xác nhận)
        if (method == 'VNPay') {
          Payment payment = Payment(userId: item.userId, cartItems: [
            CartItem(
              name: 'Order ${orderResponse.orderId}',
              id: orderResponse.orderId,
              price: item.grandTotal.toStringAsFixed(2),
              quantity: 1,
              storeId: item.storeId,
            )
          ]);
          String paymentData = paymentToJson(payment);
          _paymentFunction(paymentData);
        } else {
          // COD: không tạo URL thanh toán, giữ trạng thái pending và điều hướng
          setPaymentUrl = '';
          setLoading = false;
          Get.snackbar('Đặt hàng thành công', 'Phương thức thanh toán: COD',
              colorText: kLightWhite,
              backgroundColor: kPrimary,
              icon: const Icon(Ionicons.fast_food_outline));
          // Trở về trang chủ sau khi đặt COD
          Get.offAll(() => MainScreen());
        }
        // Không hiển thị snackbar chung ở đây cho VNPay để tránh báo thành công sớm

        // Get.offAll(() => MainScreen());
      } else {
        var error = apiErrorFromJson(response.body);

        Get.snackbar("Đặt hàng thất bại", error.message,
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Tách hàm thanh toán ra ngoài để tránh lỗi scope
  void _paymentFunction(String payment) async {
    setLoading = true;
    // Payment URL creation requires auth
    var url = Uri.parse('$appBaseUrl/api/orders/payment');
    try {
      final box = GetStorage();
      final accessToken = box.read("token");

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: payment,
      );

      // Debug logs to help diagnose payment URL creation
      print('[PAYMENT][init] status: ${response.statusCode}');
      print('[PAYMENT][init] body: ${response.body}');

      if (response.statusCode == 200) {
        var urlData = jsonDecode(response.body);
        setPaymentUrl = urlData['url'] ?? '';
        setLoading = false;
      } else {
        // Surface error to the user
        try {
          var err = jsonDecode(response.body);
          Get.snackbar('Khởi tạo thanh toán thất bại',
              err['message']?.toString() ?? 'Lỗi không xác định',
              colorText: kLightWhite,
              backgroundColor: kRed,
              icon: const Icon(Icons.error_outline));
        } catch (_) {
          Get.snackbar(
              'Khởi tạo thanh toán thất bại', 'Không thể tạo URL VNPay',
              colorText: kLightWhite,
              backgroundColor: kRed,
              icon: const Icon(Icons.error_outline));
        }
      }
    } catch (e) {
      setLoading = false;
      debugPrint(e.toString());
    } finally {
      setLoading = false;
    }
  }
}
