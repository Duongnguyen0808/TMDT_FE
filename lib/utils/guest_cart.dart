import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Key used to store guest cart items in GetStorage
const String kGuestCartKey = 'guest_cart';

/// Read guest cart from storage as a list of JSON maps
List<Map<String, dynamic>> readGuestCart(GetStorage box) {
  final dynamic raw = box.read(kGuestCartKey);
  if (raw == null) return <Map<String, dynamic>>[];

  if (raw is List) {
    try {
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: true);
    } catch (_) {
      // Fallback if items are not Map-typed
      return <Map<String, dynamic>>[];
    }
  }

  if (raw is String) {
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(growable: true);
      }
    } catch (_) {}
  }

  return <Map<String, dynamic>>[];
}

/// Persist guest cart list back to storage
void writeGuestCart(GetStorage box, List<Map<String, dynamic>> items) {
  box.write(kGuestCartKey, items);
}

/// Get current guest cart item count (number of lines, not quantities)
int guestCartCount(GetStorage box) {
  return readGuestCart(box).length;
}

/// Build a stable guest cart item id from product id and additive combo
String buildGuestItemId(String productId, List<String> additives) {
  final additivesKey = additives.isEmpty ? 'none' : additives.join('+');
  return '${productId}_$additivesKey';
}