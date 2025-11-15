import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FavoritesController extends GetxController {
  final box = GetStorage();

  // Lưu danh sách ID yêu thích để render nhanh
  final RxList<String> favIds = <String>[].obs;

  // Khóa lưu trữ trong GetStorage
  static const String _favoritesKey = 'favorites';

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() {
    final stored = box.read<List>(_favoritesKey) ?? [];
    favIds.assignAll(stored
        .map((e) => (e as Map).containsKey('id') ? e['id'].toString() : '')
        .where((id) => id.isNotEmpty));
  }

  bool isFavorite(String id) => favIds.contains(id);

  void toggleFavorite(AppliancesModel a) {
    final stored = box.read<List>(_favoritesKey) ?? [];
    final list = stored.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    if (isFavorite(a.id)) {
      favIds.remove(a.id);
      list.removeWhere((m) => m['id'] == a.id);
    } else {
      favIds.add(a.id);
      list.add({
        'id': a.id,
        'title': a.title,
        'price': a.price,
        'rating': a.rating,
        'image': a.imageUrl.isNotEmpty ? a.imageUrl.first : '',
        'time': a.time,
        'store': a.store,
      });
    }

    box.write(_favoritesKey, list);
  }

  List<Map<String, dynamic>> getFavorites() {
    final stored = box.read<List>(_favoritesKey) ?? [];
    return stored.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}