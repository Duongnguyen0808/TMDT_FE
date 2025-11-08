import 'dart:convert';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  final String userId;
  final List<CartItem> cartItems;

  Payment({
    required this.userId,
    required this.cartItems,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        userId: json["userId"],
        cartItems: List<CartItem>.from(
            json["cartItems"].map((x) => CartItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "cartItems": List<dynamic>.from(cartItems.map((x) => x.toJson())),
      };
}

class CartItem {
  final String name;
  final String id;
  final String price;
  final int quantity;
  final String storeId;

  CartItem({
    required this.name,
    required this.id,
    required this.price,
    required this.quantity,
    required this.storeId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        name: json["name"],
        id: json["id"],
        price: json["price"],
        quantity: json["quantity"],
        storeId: json["storeId"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "price": price,
        "quantity": quantity,
        "storeId": storeId,
      };
}
