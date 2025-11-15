import 'dart:convert';

OrderRequest orderRequestFromJson(String str) =>
    OrderRequest.fromJson(json.decode(str));

String orderRequestToJson(OrderRequest data) => json.encode(data.toJson());

class OrderRequest {
  final String userId;
  final List<OrderItem> orderItems;
  final double orderTotal;
  final double deliveryFee;
  final double grandTotal;
  final String deliveryAddress;
  final String storeAddress;
  final String storeId;
  final List<double> storeCoords;
  final List<double> recipientCoords;
  final String paymentMethod;
  final String? promoCode;
  final double? discountAmount;

  OrderRequest({
    required this.userId,
    required this.orderItems,
    required this.orderTotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.deliveryAddress,
    required this.storeAddress,
    required this.storeId,
    required this.storeCoords,
    required this.recipientCoords,
    required this.paymentMethod,
    this.promoCode,
    this.discountAmount,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) => OrderRequest(
        userId: json["userId"],
        orderItems: List<OrderItem>.from(
            json["orderItems"].map((x) => OrderItem.fromJson(x))),
        orderTotal: json["orderTotal"]?.toDouble(),
        deliveryFee: json["deliveryFee"]?.toDouble(),
        grandTotal: json["grandTotal"]?.toDouble(),
        deliveryAddress: json["deliveryAddress"],
        storeAddress: json["storeAddress"],
        storeId: json["storeId"],
        storeCoords:
            List<double>.from(json["storeCoords"].map((x) => x?.toDouble())),
        recipientCoords: List<double>.from(
            json["recipientCoords"].map((x) => x?.toDouble())),
        paymentMethod: json["paymentMethod"],
        promoCode: json["promoCode"],
        discountAmount: json["discountAmount"] == null
            ? null
            : (json["discountAmount"] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "orderTotal": orderTotal,
        "deliveryFee": deliveryFee,
        "grandTotal": grandTotal,
        "deliveryAddress": deliveryAddress,
        "storeAddress": storeAddress,
        "storeId": storeId,
        "storeCoords": List<dynamic>.from(storeCoords.map((x) => x)),
        "recipientCoords": List<dynamic>.from(recipientCoords.map((x) => x)),
        "paymentMethod": paymentMethod,
        "promoCode": promoCode ?? "",
        "discountAmount": discountAmount ?? 0.0,
      };
}

class OrderItem {
  final String appliancesId;
  final int quantity;
  final double price;
  final List<String> additives;
  final String instructions;

  OrderItem({
    required this.appliancesId,
    required this.quantity,
    required this.price,
    required this.additives,
    required this.instructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        appliancesId: json["appliancesId"],
        quantity: json["quantity"],
        price: json["price"]?.toDouble(),
        additives: List<String>.from(json["additives"].map((x) => x)),
        instructions: json["instructions"],
      );

  Map<String, dynamic> toJson() => {
        "appliancesId": appliancesId,
        "quantity": quantity,
        "price": price,
        "additives": List<dynamic>.from(additives.map((x) => x)),
        "instructions": instructions,
      };
}
