// ignore_for_file: unused_element

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
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

  void createOrder(String data, {VoidCallback? onAddressSet}) async {
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
        Get.snackbar(
            "Order placed successfully", "Enjoy your awesome experience",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(Ionicons.fast_food_outline));

        // Call the callback if provided
        if (onAddressSet != null) {
          onAddressSet();
        }

        // Get.offAll(() => MainScreen());
      } else {
        var error = apiErrorFromJson(response.body);

        Get.snackbar("Failed to place order", error.message,
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
