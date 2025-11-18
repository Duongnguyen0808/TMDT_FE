// To parse this JSON data, do
//
//     final appliancesModel = appliancesModelFromJson(jsonString);

import 'dart:convert';

List<AppliancesModel> appliancesModelFromJson(String str) =>
    List<AppliancesModel>.from(
        json.decode(str).map((x) => AppliancesModel.fromJson(x)));

String appliancesModelToJson(List<AppliancesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AppliancesModel {
  final String id;
  final String title;
  final String time;
  final List<String> appliancesTags;
  final String category;
  final List<String> appliancesType;
  final String code;
  final bool isAvailable;
  final String store;
  final double rating;
  final int ratingCount;
  final String description;
  final double price;
  final List<Additive> additives;
  final List<String> imageUrl;
  final double discount;
  final int? stock; // nullable to avoid breaking older responses
  final int? soldCount;

  AppliancesModel({
    required this.id,
    required this.title,
    required this.time,
    required this.appliancesTags,
    required this.category,
    required this.appliancesType,
    required this.code,
    required this.isAvailable,
    required this.store,
    required this.rating,
    required this.ratingCount,
    required this.description,
    required this.price,
    required this.additives,
    required this.imageUrl,
    required this.discount,
    this.stock,
    this.soldCount,
  });

  factory AppliancesModel.fromJson(Map<String, dynamic> json) =>
      AppliancesModel(
        id: json["_id"],
        title: json["title"],
        time: json["time"],
        appliancesTags: List<String>.from(json["appliancesTags"].map((x) => x)),
        category: json["category"],
        appliancesType: List<String>.from(json["appliancesType"].map((x) => x)),
        code: json["code"],
        isAvailable: json["isAvailable"],
        store: json["store"],
        rating: json["rating"]?.toDouble() ?? 3.0,
        ratingCount: json["ratingCount"] is int
            ? json["ratingCount"]
            : int.tryParse(json["ratingCount"].toString()) ?? 0,
        description: json["description"] ?? "",
        price: (json["price"] is int)
            ? (json["price"] as int).toDouble()
            : (json["price"]?.toDouble() ?? 0.0),
        additives: List<Additive>.from(
            json["additives"].map((x) => Additive.fromJson(x))),
        imageUrl: List<String>.from(json["imageUrl"].map((x) => x)),
        discount: (json["discount"] is int)
            ? (json["discount"] as int).toDouble()
            : (json["discount"]?.toDouble() ?? 0.0),
        stock: json.containsKey('stock')
            ? (json['stock'] is int
                ? json['stock']
                : int.tryParse(json['stock'].toString()))
            : null,
        soldCount: json.containsKey('soldCount')
            ? (json['soldCount'] is int
                ? json['soldCount']
                : int.tryParse(json['soldCount'].toString()))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "time": time,
        "appliancesTags": List<dynamic>.from(appliancesTags.map((x) => x)),
        "category": category,
        "appliancesType": List<dynamic>.from(appliancesType.map((x) => x)),
        "code": code,
        "isAvailable": isAvailable,
        "store": store,
        "rating": rating,
        "ratingCount": ratingCount,
        "description": description,
        "price": price,
        "additives": List<dynamic>.from(additives.map((x) => x.toJson())),
        "imageUrl": List<dynamic>.from(imageUrl.map((x) => x)),
        "discount": discount,
        if (stock != null) "stock": stock,
        if (soldCount != null) "soldCount": soldCount,
      };
}

class Additive {
  int id;
  String title;
  String price;

  Additive({
    required this.id,
    required this.title,
    required this.price,
  });

  factory Additive.fromJson(Map<String, dynamic> json) => Additive(
        id: json["id"],
        title: json["title"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
      };
}
