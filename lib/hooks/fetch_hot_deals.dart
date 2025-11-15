import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';

FetchHook useFetchHotDeals() {
  final appliances = useState<List<AppliancesModel>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final apiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final url = Uri.parse('$appBaseUrl/api/appliances/hot-deals');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        appliances.value = appliancesModelFromJson(response.body);
        isLoading.value = false;
      } else {
        apiError.value = apiErrorFromJson(response.body);
        isLoading.value = false;
      }
    } catch (e) {
      error.value = e as Exception;
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
    data: appliances.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
