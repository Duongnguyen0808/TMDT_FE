import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/cart_response.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

FetchHook useFetchCart() {
  final box = GetStorage();
  final cart = useState<List<CartResponse>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    String accessToken = box.read("token");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    isLoading.value = true;

    try {
      Uri url = Uri.parse('$appBaseUrl/api/cart');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        cart.value = cartResponseFromJson(response.body);
      } else {
        appiError.value = apiErrorFromJson(response.body);
      }
    } catch (e) { 
      // Avoid invalid cast when error is a TypeError
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
    data: cart.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
