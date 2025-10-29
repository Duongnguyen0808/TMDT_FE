// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:appliances_flutter/models/hook_models/store_hook.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:http/http.dart' as http;

FetchStore useFetchStores(String code) {
  final stores = useState<StoreModel?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      Uri url = Uri.parse('$appBaseUrl/api/store/byId/$code');
      final response = await http.get(url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var store = jsonDecode(response.body);
        stores.value = StoreModel.fromJson(store);
      } else {
        appiError.value = apiErrorFromJson(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
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

  return FetchStore(
    data: stores.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
