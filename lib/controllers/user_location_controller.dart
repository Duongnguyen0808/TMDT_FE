// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:appliances_flutter/config/vietmap_config.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appliances_flutter/vendor/vietmap_platform.dart';
import 'package:http/http.dart' as http;

class UserLocationController extends GetxController {
  RxBool _isDefault = false.obs;

  bool get isDefault => _isDefault.value;

  set setIsDefault(bool value) {
    _isDefault.value = value;
  }

  RxInt _tabIndex = 0.obs;

  int get tabIndex => _tabIndex.value;

  set setTabIndex(int value) {
    _tabIndex.value = value;
  }

  LatLng position = LatLng(0, 0);

  void setPosition(LatLng value) {
    position = value;
    update();
  }

  RxString _address = ''.obs;

  String get address => _address.value;

  set setAddress(String value) {
    _address.value = value;
  }

  RxString _address1 = ''.obs;

  String get address1 => _address1.value;

  set setAddress1(String value) {
    _address1.value = value;
  }

  void getUserAddress(LatLng position) async {
    // Thử sử dụng Vietmap reverse geocoding trước
    if (hasRealVietmapKey()) {
      try {
        final url = Uri.parse(
            'https://maps.vietmap.vn/api/reverse/v3?apikey=$vietmapApiKey&lng=${position.longitude}&lat=${position.latitude}');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);

          if (responseBody != null && responseBody.isNotEmpty) {
            final address = responseBody[0]['display'];
            setAddress = address;
            return;
          }
        }
      } catch (e) {
        print('Vietmap reverse geocoding failed: $e');
      }
    }

    // Fallback to Nominatim (OpenStreetMap) reverse geocoding
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1');

      final response =
          await http.get(url, headers: {'User-Agent': 'Flutter App'});

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        final address = responseBody['display_name'] ?? '';
        setAddress = address;
      }
    } catch (e) {
      print('Nominatim reverse geocoding failed: $e');
      setAddress = 'Không thể lấy địa chỉ';
    }
  }

  void addAddress(String data, {VoidCallback? onAddressSet}) async {
    final box = GetStorage();
    String accessToken = box.read("token");

    Uri url = Uri.parse('$appBaseUrl/api/address');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      var response = await http.post(url, headers: headers, body: data);

      if (response.statusCode == 201) {
        Get.snackbar("Thêm địa chỉ thành công", "Địa chỉ của bạn đã được lưu",
            colorText: kLightWhite,
            backgroundColor: kPrimary);

        // Call the callback if provided
        if (onAddressSet != null) {
          onAddressSet();
        }

        Get.offAll(() => MainScreen());
      } else {
        var error = apiErrorFromJson(response.body);

        Get.snackbar("Thêm địa chỉ thất bại", error.message,
            colorText: kLightWhite,
            backgroundColor: kRed);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
