import 'package:appliances_flutter/models/promotion_model.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:appliances_flutter/services/api_client.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

FetchHook useFetchPromotions() {
  final dataState = useState<List<PromotionModel>?>(null);
  final isLoadingState = useState(false);
  final errorState = useState<Exception?>(null);

  Future<void> fetch() async {
    isLoadingState.value = true;
    try {
      final res = await ApiClient.instance.get('/api/promotions',
          useCache: true, ttl: const Duration(seconds: 20));
      if (res.ok && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final list = (map['promotions'] as List?) ?? [];
        dataState.value = list
            .whereType<Map<String, dynamic>>()
            .map((e) => PromotionModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      errorState.value = e is Exception ? e : Exception(e.toString());
    } finally {
      isLoadingState.value = false;
    }
  }

  useEffect(() {
    fetch();
    return null;
  }, []);

  void refetch() => fetch();

  return FetchHook(
    data: dataState.value,
    isLoading: isLoadingState.value,
    error: errorState.value,
    refetch: refetch,
  );
}
