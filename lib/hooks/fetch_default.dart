import 'dart:convert';

import 'package:appliances_flutter/common/address_buttom_sheet.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/user_location_controller.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

FetchHook useFetchDefault(BuildContext context) {
  final controller = Get.put(UserLocationController());
  final box = GetStorage();
  final addresses = useState<AddressResponse?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    String? accessToken = box.read("token");
    final bool isLoggedIn = accessToken != null &&
        accessToken.isNotEmpty &&
        accessToken != 'null' &&
        accessToken != 'undefined';

    // Nếu chưa đăng nhập: bỏ qua hoàn toàn, tránh gọi API và tránh mở sheet
    if (!isLoggedIn) {
      addresses.value = null;
      isLoading.value = false;
      return;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    isLoading.value = true;

    try {
      // Kiểm tra xem user có địa chỉ nào không
      Uri checkUrl = Uri.parse('$appBaseUrl/api/address/all');
      final checkResponse = await http.get(checkUrl, headers: headers);

      bool hasAnyAddress = false;
      if (checkResponse.statusCode == 200) {
        var checkData = jsonDecode(checkResponse.body);
        // API trả về {addresses: [...]}
        if (checkData['addresses'] != null &&
            checkData['addresses'] is List &&
            (checkData['addresses'] as List).isNotEmpty) {
          hasAnyAddress = true;
        }
      }

      // Lấy địa chỉ mặc định
      Uri url = Uri.parse('$appBaseUrl/api/address/default');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var data = response.body;
        var decoded = jsonDecode(data);
        // Backend trả về {address: {...}} hoặc {address: null}
        if (decoded['address'] != null) {
          addresses.value = AddressResponse.fromJson(decoded['address']);
          controller.setAddress1 = addresses.value!.addressLine1;
        } else {
          addresses.value = null;
          // Chỉ hiện popup nếu chưa có địa chỉ nào
          if (!hasAnyAddress) {
            showAddressSheet(context);
          }
        }
      } else {
        // Chỉ hiện popup nếu chưa có địa chỉ nào
        if (!hasAnyAddress) {
          showAddressSheet(context);
        }
        appiError.value = apiErrorFromJson(response.body);
      }
    } catch (e) {
      // Không hiển thị sheet khi lỗi nữa, người dùng có thể tự thêm sau
      error.value = e is Exception ? e : Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  useEffect(() {
    fetchData();
    return null;
  }, []);

  void refetch() {
    isLoading.value = true;
    fetchData();
  }

  return FetchHook(
    data: addresses.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
