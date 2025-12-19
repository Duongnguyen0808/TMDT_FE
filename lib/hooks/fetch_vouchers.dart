import 'package:appliances_flutter/models/voucher.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:appliances_flutter/services/api_client.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Fetch vouchers available for current user to claim
FetchHook useFetchAvailableVouchers() {
  final dataState = useState<List<Voucher>?>(null);
  final isLoadingState = useState(false);
  final errorState = useState<Exception?>(null);

  Future<void> fetch() async {
    isLoadingState.value = true;
    try {
      final res = await ApiClient.instance.get('/api/voucher/available',
          useCache: false, ttl: const Duration(seconds: 10));
      if (res.ok && res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final list = (map['data'] as List?) ?? [];
        dataState.value = list
            .whereType<Map<String, dynamic>>()
            .map((e) => Voucher.fromJson(e))
            .toList();
      } else {
        dataState.value = <Voucher>[];
      }
    } catch (e) {
      errorState.value = e is Exception ? e : Exception(e.toString());
      dataState.value = <Voucher>[];
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
