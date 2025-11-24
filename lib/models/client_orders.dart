// To parse this JSON data, do
//
//     final clientOrders = clientOrdersFromJson(jsonString);

import 'dart:convert';

List<ClientOrders> clientOrdersFromJson(String str) => List<ClientOrders>.from(
    json.decode(str).map((x) => ClientOrders.fromJson(x)));

String clientOrdersToJson(List<ClientOrders> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClientOrders {
  final String id;
  final String userId;
  final List<OrderItem> orderItems;
  final double orderTotal;
  final double deliveryFee;
  final double grandTotal;
  final String deliveryAddress;
  final String storeAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? logisticStatus;
  final String storeId;
  final List<double> storeCoords;
  final List<double> recipientCoords;
  final String driverId;
  final int rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? promoCode;
  final double? discountAmount;
  final String? returnStatus;
  final String? returnReason;
  final double? refundAmount;
  final String? pickupCode;
  final DateTime? pickupCodeExpiresAt;
  final DateTime? pickupReadyAt;
  final DateTime? pickupAssignedAt;
  final DateTime? pickupCheckinAt;
  final PickupCheckinLocation? pickupCheckinLocation;
  final DateTime? pickupConfirmedAt;
  final String? shopReadyBy;
  final String? shipperPickupBy;
  final String? pickupNotes;
  final String? handoverPhoto;

  ClientOrders({
    required this.id,
    required this.userId,
    required this.orderItems,
    required this.orderTotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.deliveryAddress,
    required this.storeAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.logisticStatus,
    required this.storeId,
    required this.storeCoords,
    required this.recipientCoords,
    required this.driverId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.promoCode,
    this.discountAmount,
    this.returnStatus,
    this.returnReason,
    this.refundAmount,
    this.pickupCode,
    this.pickupCodeExpiresAt,
    this.pickupReadyAt,
    this.pickupAssignedAt,
    this.pickupCheckinAt,
    this.pickupCheckinLocation,
    this.pickupConfirmedAt,
    this.shopReadyBy,
    this.shipperPickupBy,
    this.pickupNotes,
    this.handoverPhoto,
  });

  factory ClientOrders.fromJson(Map<String, dynamic> json) => ClientOrders(
        id: json["_id"],
        userId: json["userId"],
        orderItems: List<OrderItem>.from(
            json["orderItems"].map((x) => OrderItem.fromJson(x))),
        orderTotal: json["orderTotal"]?.toDouble(),
        deliveryFee: json["deliveryFee"]?.toDouble(),
        grandTotal: json["grandTotal"]?.toDouble(),
        deliveryAddress: json["deliveryAddress"] is String
            ? json["deliveryAddress"]
            : json["deliveryAddress"]?["addressLine1"] ?? "",
        storeAddress: json["storeAddress"],
        paymentMethod: json["paymentMethod"],
        paymentStatus: json["paymentStatus"],
        orderStatus: json["orderStatus"],
        logisticStatus: json["logisticStatus"],
        storeId: json["storeId"],
        storeCoords:
            List<double>.from(json["storeCoords"].map((x) => x?.toDouble())),
        recipientCoords: List<double>.from(
            json["recipientCoords"].map((x) => x?.toDouble())),
        driverId: json["driverId"],
        rating: json["rating"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        cancellationReason: json["cancellationReason"],
        cancelledBy: json["cancelledBy"],
        cancelledAt: _parseDate(json["cancelledAt"]),
        promoCode: json["promoCode"],
        discountAmount: json["discountAmount"]?.toDouble(),
        returnStatus: json["returnStatus"],
        returnReason: json["returnReason"],
        refundAmount: json["refundAmount"]?.toDouble(),
        pickupCode: json["pickupCode"],
        pickupCodeExpiresAt: _parseDate(json["pickupCodeExpiresAt"]),
        pickupReadyAt: _parseDate(json["pickupReadyAt"]),
        pickupAssignedAt: _parseDate(json["pickupAssignedAt"]),
        pickupCheckinAt: _parseDate(json["pickupCheckinAt"]),
        pickupCheckinLocation: json["pickupCheckinLocation"] is Map
            ? PickupCheckinLocation.fromJson(json["pickupCheckinLocation"])
            : null,
        pickupConfirmedAt: _parseDate(json["pickupConfirmedAt"]),
        shopReadyBy: json["shopReadyBy"],
        shipperPickupBy: json["shipperPickupBy"],
        pickupNotes: json["pickupNotes"],
        handoverPhoto: json["handoverPhoto"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "orderTotal": orderTotal,
        "deliveryFee": deliveryFee,
        "grandTotal": grandTotal,
        "deliveryAddress": deliveryAddress,
        "storeAddress": storeAddress,
        "paymentMethod": paymentMethod,
        "paymentStatus": paymentStatus,
        "orderStatus": orderStatus,
        "logisticStatus": logisticStatus,
        "storeId": storeId,
        "storeCoords": List<dynamic>.from(storeCoords.map((x) => x)),
        "recipientCoords": List<dynamic>.from(recipientCoords.map((x) => x)),
        "driverId": driverId,
        "rating": rating,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "cancellationReason": cancellationReason,
        "cancelledBy": cancelledBy,
        "cancelledAt": cancelledAt?.toIso8601String(),
        "promoCode": promoCode,
        "discountAmount": discountAmount,
        "returnStatus": returnStatus,
        "returnReason": returnReason,
        "refundAmount": refundAmount,
        "pickupCode": pickupCode,
        "pickupCodeExpiresAt": pickupCodeExpiresAt?.toIso8601String(),
        "pickupReadyAt": pickupReadyAt?.toIso8601String(),
        "pickupAssignedAt": pickupAssignedAt?.toIso8601String(),
        "pickupCheckinAt": pickupCheckinAt?.toIso8601String(),
        "pickupCheckinLocation": pickupCheckinLocation?.toJson(),
        "pickupConfirmedAt": pickupConfirmedAt?.toIso8601String(),
        "shopReadyBy": shopReadyBy,
        "shipperPickupBy": shipperPickupBy,
        "pickupNotes": pickupNotes,
        "handoverPhoto": handoverPhoto,
      };
}

class PickupCheckinLocation {
  final double latitude;
  final double longitude;

  PickupCheckinLocation({required this.latitude, required this.longitude});

  factory PickupCheckinLocation.fromJson(Map<String, dynamic> json) =>
      PickupCheckinLocation(
        latitude: (json["latitude"] as num?)?.toDouble() ?? 0,
        longitude: (json["longitude"] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    try {
      return DateTime.parse(value);
    } catch (_) {}
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return null;
}

class OrderItem {
  final AppliancesId appliancesId;
  final int quantity;
  final double price;
  final List<String> additives;
  final String instructions;
  final String id;

  OrderItem({
    required this.appliancesId,
    required this.quantity,
    required this.price,
    required this.additives,
    required this.instructions,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        appliancesId: json["appliancesId"] != null
            ? AppliancesId.fromJson(json["appliancesId"])
            : AppliancesId(
                id: "", title: "Unknown", rating: 0, imageUrl: [], time: ""),
        quantity: json["quantity"] ?? 0,
        price: json["price"]?.toDouble() ?? 0.0,
        additives: json["additives"] != null
            ? List<String>.from(json["additives"].map((x) => x))
            : [],
        instructions: json["instructions"] ?? "",
        id: json["_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "appliancesId": appliancesId.toJson(),
        "quantity": quantity,
        "price": price,
        "additives": List<dynamic>.from(additives.map((x) => x)),
        "instructions": instructions,
        "_id": id,
      };
}

class AppliancesId {
  final String id;
  final String title;
  final double rating;
  final List<String> imageUrl;
  final String time;

  AppliancesId({
    required this.id,
    required this.title,
    required this.rating,
    required this.imageUrl,
    required this.time,
  });

  factory AppliancesId.fromJson(Map<String, dynamic> json) => AppliancesId(
        id: json["_id"] ?? "",
        title: json["title"] ?? "Unknown",
        rating: json["rating"]?.toDouble() ?? 0.0,
        imageUrl: json["imageUrl"] != null
            ? List<String>.from(json["imageUrl"].map((x) => x))
            : [],
        time: json["time"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "rating": rating,
        "imageUrl": List<dynamic>.from(imageUrl.map((x) => x)),
        "time": time,
      };
}
