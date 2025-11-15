// ignore_for_file: unused_local_variable

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/category_controller.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/hook_models/appliances_hook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

FetchAppliancess useFetchAppliancesByCategory(String code) {
  final controller = Get.put(CategoryController());
  final appliancess = useState<List<AppliancesModel>>([]);
  final isLoading = useState<bool>(false);
  final error = useState<Exception?>(null);
  final appiError = useState<ApiError?>(null);

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      // Nếu code rỗng, chỉ lấy theo category. Ngược lại lấy theo cả category và code
      Uri url = code.isEmpty
          ? Uri.parse(
              '$appBaseUrl/api/appliances/category/${controller.categoryValue}')
          : Uri.parse(
              '$appBaseUrl/api/appliances/${controller.categoryValue}/$code');

      print('🔍 Category ID: ${controller.categoryValue}');
      print('🔍 Fetching URL: $url');

      final response = await http.get(url);

      print('📡 Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        appliancess.value = appliancesModelFromJson(response.body);
        print('✅ Found ${appliancess.value.length} products');
      } else {
        print('❌ Error: ${response.body}');
      }
    } catch (e) {
      print('💥 Exception: $e');
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  useEffect(() {
    // Chỉ fetch khi có categoryValue
    if (controller.categoryValue.isNotEmpty) {
      fetchData();
    }
    return null;
  }, [controller.categoryValue]);

  void refetch() {
    isLoading.value = true;
    fetchData();
  }

  return FetchAppliancess(
    data: appliancess.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
