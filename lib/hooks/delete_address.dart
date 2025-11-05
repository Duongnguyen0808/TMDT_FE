import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class DeleteAddressHook {
  final bool isLoading;
  final Exception? error;
  final Future<bool> Function(String addressId) deleteAddress;

  DeleteAddressHook({
    required this.isLoading,
    required this.error,
    required this.deleteAddress,
  });
}

DeleteAddressHook useDeleteAddress() {
  final box = GetStorage();
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);

  Future<bool> deleteAddress(String addressId) async {
    String accessToken = box.read("token");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    isLoading.value = true;
    error.value = null;

    try {
      Uri url = Uri.parse('$appBaseUrl/api/address/$addressId');
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['status'] == true;
      } else {
        error.value = Exception(
            'API Error: ${response.statusCode} - ${jsonDecode(response.body)['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      error.value = e is Exception ? e : Exception(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  return DeleteAddressHook(
    isLoading: isLoading.value,
    error: error.value,
    deleteAddress: deleteAddress,
  );
}
