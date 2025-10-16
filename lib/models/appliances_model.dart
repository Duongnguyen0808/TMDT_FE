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
  final String ratingCount;
  final String description;
  final double price;
  final List<Additive> additives;
  final List<String> imageUrl;

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
        rating: json["rating"]?.toDouble(),
        ratingCount: json["ratingCount"],
        description: json["description"],
        price: json["price"]?.toDouble(),
        additives: List<Additive>.from(
            json["additives"].map((x) => Additive.fromJson(x))),
        imageUrl: List<String>.from(json["imageUrl"].map((x) => x)),
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
