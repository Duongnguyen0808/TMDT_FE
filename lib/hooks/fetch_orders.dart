import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

FetchHook useFetchOrders(String orderStatus, [String? paymentStatus]) {
  final box = GetStorage();
  final orders = useState<List<ClientOrders>>([]);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    String? accessToken = box.read("token");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    isLoading.value = true;

    try {
      // Chỉ thêm paymentStatus nếu được cung cấp
      String queryString = 'orderStatus=$orderStatus';
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryString += '&paymentStatus=$paymentStatus';
      }

      Uri url = Uri.parse('$appBaseUrl/api/orders?$queryString');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final parsed = clientOrdersFromJson(response.body);
        parsed.sort(_orderComparator);
        orders.value = parsed;
      } else {
        appiError.value = apiErrorFromJson(response.body);
      }
    } catch (e) {
      // Tránh lỗi cast khi e là TypeError/ Error thay vì Exception
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
    data: orders.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}

int _orderComparator(ClientOrders a, ClientOrders b) {
  final bool aNeedsConfirm = _needsReceiptConfirmation(a);
  final bool bNeedsConfirm = _needsReceiptConfirmation(b);
  if (aNeedsConfirm != bNeedsConfirm) {
    return aNeedsConfirm ? -1 : 1;
  }
  return b.createdAt.compareTo(a.createdAt);
}

bool _needsReceiptConfirmation(ClientOrders order) {
  final status = order.orderStatus;
  final shopStatus = (order.shopDeliveryConfirmStatus ?? 'None');
  final hasProof = (order.deliveryProofPhoto ?? '').isNotEmpty;
  final bool awaitingShopConfirmation = shopStatus != 'Confirmed';
  final bool inDeliveryPhase = status == 'Delivering' || status == 'Delivered';
  if (awaitingShopConfirmation && hasProof && inDeliveryPhase) {
    return true;
  }
  final bool codPending =
      order.paymentMethod == 'COD' && order.paymentStatus == 'Pending';
  return status == 'Delivered' && codPending;
}
