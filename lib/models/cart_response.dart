// To parse this JSON data, do
//
//     final cartResponse = cartResponseFromJson(jsonString);

import 'dart:convert';

// Helpers to safely parse dynamic values that may be numbers or strings
double _parseDouble(dynamic v, [double fallback = 0.0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

// Supports both: [{...}, {...}] and { "cart": [{...}, {...}] }
List<CartResponse> cartResponseFromJson(String str) {
  final decoded = json.decode(str);
  final List<dynamic> items = decoded is List
      ? decoded
      : (decoded['cart'] ?? []);
  return List<CartResponse>.from(items.map((x) => CartResponse.fromJson(x)));
}

String cartResponseToJson(List<CartResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartResponse {
  final String id;
  final ProductId productId;
  final List<String> additives;
  final double totalPrice;
  final int quantity;

  CartResponse({
    required this.id,
    required this.productId,
    required this.additives,
    required this.totalPrice,
    required this.quantity,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final dynamic pidRaw = json["productId"];
    final ProductId product;
    if (pidRaw is Map<String, dynamic>) {
      product = ProductId.fromJson(pidRaw);
    } else {
      // Legacy/guest items may store only the id as a string
      final dynamic storeRaw = json["store"];
      final Map<String, dynamic> storeMap =
          storeRaw is Map ? Map<String, dynamic>.from(storeRaw) : {};
      final dynamic imgRaw = json["imageUrl"];
      final List<String> images = imgRaw is List
          ? List<String>.from(imgRaw.map((x) => x.toString()))
          : <String>[];
      product = ProductId(
        id: (pidRaw ?? "").toString(),
        title: (json["title"] ?? json["productTitle"] ?? "").toString(),
        store: CartStore.fromJson(storeMap),
        rating: _parseDouble(json["rating"]),
        ratingCount: (json["ratingCount"] ?? "0").toString(),
        imageUrl: images,
      );
    }

    return CartResponse(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      productId: product,
      additives: List<String>.from((json["additives"] ?? []).map((x) => x.toString())),
      totalPrice: _parseDouble(json["totalPrice"]),
      quantity: _parseInt(json["quantity"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "productId": productId.toJson(),
        "additives": List<dynamic>.from(additives.map((x) => x)),
        "totalPrice": totalPrice,
        "quantity": quantity,
      };
}

class ProductId {
  final String id;
  final String title;
  final CartStore store;
  final double rating;
  final String ratingCount;
  final List<String> imageUrl;

  ProductId({
    required this.id,
    required this.title,
    required this.store,
    required this.rating,
    required this.ratingCount,
    required this.imageUrl,
  });

  factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
        id: (json["_id"] ?? json["id"] ?? "").toString(),
        title: (json["title"] ?? "").toString(),
        store: CartStore.fromJson(
          json["store"] is Map
              ? Map<String, dynamic>.from(json["store"])
              : <String, dynamic>{},
        ),
        rating: _parseDouble(json["rating"]),
        ratingCount: (json["ratingCount"] ?? "0").toString(),
        imageUrl: (json["imageUrl"] is List)
            ? List<String>.from((json["imageUrl"] as List)
                .map((x) => x.toString()))
            : <String>[],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "store": store.toJson(),
        "rating": rating,
        "ratingCount": ratingCount,
        "imageUrl": List<dynamic>.from(imageUrl.map((x) => x)),
      };
}

class CartStore {
  final String id;
  final String time;
  final CartCoords coords;

  CartStore({
    required this.id,
    required this.time,
    required this.coords,
  });

  factory CartStore.fromJson(Map<String, dynamic> json) {
    final dynamic coordsRaw = json["coords"];
    final Map<String, dynamic> coordsMap = coordsRaw is Map
        ? Map<String, dynamic>.from(coordsRaw)
        : <String, dynamic>{};
    // Ensure we do NOT stringify null -> "null". Prefer empty string if missing.
    final dynamic idRaw = json["_id"]; // Mongoose usually includes _id by default
    final String storeId = idRaw == null ? "" : idRaw.toString();

    return CartStore(
      id: storeId,
      time: (json["time"] ?? "").toString(),
      coords: CartCoords.fromJson(coordsMap),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "time": time,
        "coords": coords.toJson(),
      };
}

class CartCoords {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String title;
  final double latitudeDelta;
  final double longitudeDelta;

  CartCoords({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.title,
    required this.latitudeDelta,
    required this.longitudeDelta,
  });

  factory CartCoords.fromJson(Map<String, dynamic> json) => CartCoords(
        id: (json["id"] ?? json["_id"] ?? "").toString(),
        latitude: _parseDouble(json["latitude"]),
        longitude: _parseDouble(json["longitude"]),
        address: json["address"] ?? "",
        title: json["title"] ?? "",
        latitudeDelta: _parseDouble(json["latitudeDelta"]),
        longitudeDelta: _parseDouble(json["longitudeDelta"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "title": title,
        "latitudeDelta": latitudeDelta,
        "longitudeDelta": longitudeDelta,
      };
}
