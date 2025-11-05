import 'dart:convert';

OrderModel orderModelFromJson(String str) =>
    OrderModel.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

class OrderModel {
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
  final String storeId;
  final List<double> storeCoords;
  final List<double> recipientCoords;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  OrderModel({
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
    required this.storeId,
    required this.storeCoords,
    required this.recipientCoords,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json["_id"],
        userId: json["userId"],
        orderItems: List<OrderItem>.from(
            json["orderItems"].map((x) => OrderItem.fromJson(x))),
        orderTotal: json["orderTotal"]?.toDouble(),
        deliveryFee: json["deliveryFee"]?.toDouble(),
        grandTotal: json["grandTotal"]?.toDouble(),
        deliveryAddress: json["deliveryAddress"],
        storeAddress: json["storeAddress"],
        paymentMethod: json["paymentMethod"],
        paymentStatus: json["paymentStatus"],
        orderStatus: json["orderStatus"],
        storeId: json["storeId"],
        storeCoords:
            List<double>.from(json["storeCoords"].map((x) => x?.toDouble())),
        recipientCoords: List<double>.from(
            json["recipientCoords"].map((x) => x?.toDouble())),
        orderDate: DateTime.parse(json["orderDate"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
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
        "storeId": storeId,
        "storeCoords": List<dynamic>.from(storeCoords.map((x) => x)),
        "recipientCoords": List<dynamic>.from(recipientCoords.map((x) => x)),
        "orderDate": orderDate.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
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
        appliancesId: AppliancesId.fromJson(json["appliancesId"]),
        quantity: json["quantity"],
        price: json["price"]?.toDouble(),
        additives: List<String>.from(json["additives"].map((x) => x)),
        instructions: json["instructions"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "foappliancesIdodId": appliancesId.toJson(),
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
        id: json["_id"],
        title: json["title"],
        rating: json["rating"]?.toDouble(),
        imageUrl: List<String>.from(json["imageUrl"].map((x) => x)),
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "rating": rating,
        "imageUrl": List<dynamic>.from(imageUrl.map((x) => x)),
        "time": time,
      };
}
