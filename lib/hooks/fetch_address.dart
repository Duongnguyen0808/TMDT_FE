import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/hook_models/addresses.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

FetchAddresses useFetchAddresses() {
  final box = GetStorage();
  final addresses = useState<List<AddressResponse>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);

  Future<void> fetchData() async {
    String accessToken = box.read("token");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    isLoading.value = true;

    try {
      Uri url = Uri.parse('$appBaseUrl/api/address/all');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> addressesData = decoded is Map<String, dynamic>
            ? (decoded['addresses'] ?? [])
            : (decoded as List<dynamic>? ?? []);

        // Chỉ nhận các phần tử là Map và parse an toàn
        addresses.value = addressesData
            .whereType<Map<String, dynamic>>()
            .map((json) => AddressResponse.fromJson(json))
            .toList();
      } else {
        final msg = () {
          try {
            final body = jsonDecode(response.body);
            return body is Map<String, dynamic>
                ? (body['message'] ?? 'Unknown error')
                : 'Unknown error';
          } catch (_) {
            return 'Unknown error';
          }
        }();
        error.value = Exception('API Error: ${response.statusCode} - $msg');
      }
    } on TypeError catch (e) {
      // Trường JSON null/sai kiểu sẽ vào đây
      error.value = Exception('Parse error: ${e.toString()}');
    } catch (e) {
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

  return FetchAddresses(
    data: addresses.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
