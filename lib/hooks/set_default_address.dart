import 'dart:convert';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SetDefaultAddressHook {
  final bool isLoading;
  final Exception? error;
  final ApiError? apiError;
  final Future<bool> Function(String addressId) setDefaultAddress;

  SetDefaultAddressHook({
    required this.isLoading,
    required this.error,
    required this.apiError,
    required this.setDefaultAddress,
  });
}

SetDefaultAddressHook useSetDefaultAddress() {
  final box = GetStorage();
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final apiError = useState<ApiError?>(null);

  Future<bool> setDefaultAddress(String addressId) async {
    String? accessToken = box.read("token");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    isLoading.value = true;
    error.value = null;
    apiError.value = null;

    try {
      Uri url = Uri.parse('$appBaseUrl/api/address/default/$addressId');
      final response = await http.patch(url, headers: headers);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == true) {
          return true;
        } else {
          apiError.value = ApiError(
              status: false,
              message: data['message'] ?? 'Failed to set default address');
          return false;
        }
      } else {
        apiError.value = apiErrorFromJson(response.body);
        return false;
      }
    } catch (e) {
      error.value = e is Exception ? e : Exception(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  return SetDefaultAddressHook(
    isLoading: isLoading.value,
    error: error.value,
    apiError: apiError.value,
    setDefaultAddress: setDefaultAddress,
  );
}
