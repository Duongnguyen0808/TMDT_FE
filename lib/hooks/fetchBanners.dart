// ignore_for_file: file_names

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/banner_model.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

FetchHook useFetchBanners() {
  final banners = useState<List<BannerModel>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final apiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;
    error.value = null;
    apiError.value = null;

    try {
      final url = Uri.parse('$appBaseUrl/api/banners');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        banners.value = bannerModelFromJson(response.body);
      } else {
        try {
          apiError.value = apiErrorFromJson(response.body);
        } catch (_) {
          error.value =
              Exception('Không thể tải banner (${response.statusCode})');
        }
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
    fetchData();
  }

  return FetchHook(
    data: banners.value,
    isLoading: isLoading.value,
    error: error.value ??
        (apiError.value != null
            ? Exception(apiError.value?.message ?? 'Đã có lỗi xảy ra')
            : null),
    refetch: refetch,
  );
}
