// To parse this JSON data, do
//
//     final cartResponse = cartResponseFromJson(jsonString);

import 'dart:convert';

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

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
        id: json["_id"],
        productId: ProductId.fromJson(json["productId"]),
        additives: List<String>.from(json["additives"].map((x) => x)),
        totalPrice: json["totalPrice"]?.toDouble(),
        quantity: json["quantity"],
      );

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
        id: json["_id"],
        title: json["title"],
        store: CartStore.fromJson(json["store"]),
        rating: json["rating"]?.toDouble(),
        ratingCount: json["ratingCount"],
        imageUrl: List<String>.from(json["imageUrl"].map((x) => x)),
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

  factory CartStore.fromJson(Map<String, dynamic> json) => CartStore(
        id: (json["_id"] ?? json["id"]).toString(),
        time: json["time"] ?? "",
        coords: CartCoords.fromJson(json["coords"] ?? {}),
      );

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
        latitude: (json["latitude"] ?? 0.0).toDouble(),
        longitude: (json["longitude"] ?? 0.0).toDouble(),
        address: json["address"] ?? "",
        title: json["title"] ?? "",
        latitudeDelta: (json["latitudeDelta"] ?? 0.0).toDouble(),
        longitudeDelta: (json["longitudeDelta"] ?? 0.0).toDouble(),
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
