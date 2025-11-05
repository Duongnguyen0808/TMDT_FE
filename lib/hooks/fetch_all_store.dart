import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:appliances_flutter/models/store_model.dart';

import 'package:http/http.dart' as http;

FetchHook useFetchAllStore(String code) {
  final stores = useState<List<StoreModel>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      Uri url = Uri.parse('$appBaseUrl/api/store/all/$code');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        stores.value = storeModelFromJson(response.body);
      } else {
        appiError.value = apiErrorFromJson(response.body);
      }
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

  return FetchHook(
    data: stores.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
