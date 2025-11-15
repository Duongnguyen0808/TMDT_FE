import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/cart_response.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:appliances_flutter/utils/guest_cart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/foundation.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

FetchHook useFetchCart() {
  final box = GetStorage();
  final cart = useState<List<CartResponse>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      // Đọc token có thể trả về null sau khi đăng xuất
      final String? accessToken = box.read("token");

      // Nếu chưa đăng nhập, không gọi API và thoát sớm
      if (accessToken == null ||
          accessToken.isEmpty ||
          accessToken == 'null' ||
          accessToken == 'undefined') {
        // Fallback: đọc giỏ khách từ local storage
        try {
          final raw = readGuestCart(box);
          final list =
              raw.map((e) => CartResponse.fromJson(e)).toList(growable: false);
          cart.value = list;
        } catch (e) {
          // Nếu parse lỗi, vẫn set giỏ trống
          cart.value = <CartResponse>[];
        }
        return;
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      Uri url = Uri.parse('$appBaseUrl/api/cart');
      final response = await http.get(url, headers: headers);
      debugPrint('[Cart] GET /api/cart -> ${response.statusCode}');
      if (response.body.isNotEmpty) {
        debugPrint('[Cart] Response length: ${response.body.length}');
      }

      if (response.statusCode == 200) {
        try {
          final items = cartResponseFromJson(response.body);
          debugPrint('[Cart] Parsed items: ${items.length}');
          if (items.isEmpty && response.body.isNotEmpty) {
            final preview = response.body.length > 300
                ? response.body.substring(0, 300)
                : response.body;
            debugPrint('[Cart] Parsed empty, body preview: ' + preview);
          }
          cart.value = items;
        } catch (e) {
          debugPrint('[Cart] Parse error: ' + e.toString());
          error.value = e is Exception ? e : Exception(e.toString());
        }
      } else {
        appiError.value = apiErrorFromJson(response.body);
        // Đảm bảo UI không giữ data cũ khi gặp lỗi
        cart.value = <CartResponse>[];
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
