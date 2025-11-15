// ignore_for_file: avoid_print

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:appliances_flutter/utils/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:http/http.dart' as http;

FetchHook useFetchAllAppliances(String code) {
  final appliancess = useState<List<AppliancesModel>?>(null);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      // Lấy tất cả sản phẩm nếu code rỗng, hoặc lọc theo code nếu có
      Uri url = code.isEmpty
          ? Uri.parse(
              ApiHelper.addLanguageParam('$appBaseUrl/api/appliances/all'))
          : Uri.parse(ApiHelper.addLanguageParam(
              '$appBaseUrl/api/appliances/byCode/$code'));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        appliancess.value = appliancesModelFromJson(response.body);
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

  return FetchHook(
    data: appliancess.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
