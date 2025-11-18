import 'dart:convert';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/hook_models/hook_result.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class UserRatingItem {
  final String id;
  final String ratingType; // Store | Appliances | Driver
  final String product; // id tham chiếu
  final double rating;
  final String comment;
  final DateTime createdAt;
  final Map<String, dynamic>?
      entity; // enriched entity from backend (Store / Appliances minimal fields)

  UserRatingItem({
    required this.id,
    required this.ratingType,
    required this.product,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.entity,
  });

  factory UserRatingItem.fromJson(Map<String, dynamic> json) => UserRatingItem(
        id: json['_id'] ?? '',
        ratingType: json['ratingType'] ?? '',
        product: json['product'] ?? '',
        rating: (json['rating'] is int)
            ? (json['rating'] as int).toDouble()
            : (json['rating']?.toDouble() ?? 0.0),
        comment: json['comment'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        entity: json['entity'] is Map<String, dynamic>
            ? json['entity'] as Map<String, dynamic>
            : null,
      );
}

FetchHook useFetchMyRatings() {
  final dataState = useState<List<UserRatingItem>?>(null);
  final isLoadingState = useState(false);
  final errorState = useState<Exception?>(null);

  Future<void> fetch() async {
    isLoadingState.value = true;
    try {
      final box = GetStorage();
      final token = box.read('token');
      if (token == null) {
        dataState.value = [];
        isLoadingState.value = false;
        return;
      }
      final url = Uri.parse('$appBaseUrl/api/ratings/mine');
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final List list = map['ratings'] ?? [];
        dataState.value = list
            .map((e) => UserRatingItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      isLoadingState.value = false;
    } catch (e) {
      errorState.value = e as Exception;
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
