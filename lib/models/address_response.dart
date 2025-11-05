// To parse this JSON data, do
//
//     final addressResponse = addressResponseFromJson(jsonString);

import 'dart:convert';

List<AddressResponse> addressResponseFromJson(String str) =>
    List<AddressResponse>.from(
        json.decode(str).map((x) => AddressResponse.fromJson(x)));

String addressResponseToJson(List<AddressResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddressResponse {
  final String id;
  final String userId;
  final String addressLine1;
  final bool addressResponseDefault;
  final String deliveryInstructions;
  final double latitude;
  final double longitude;
  final int v;

  AddressResponse({
    required this.id,
    required this.userId,
    required this.addressLine1,
    required this.addressResponseDefault,
    required this.deliveryInstructions,
    required this.latitude,
    required this.longitude,
    required this.v,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      AddressResponse(
        id: (json["_id"]?.toString() ?? ""),
        userId: (json["userId"]?.toString() ?? ""),
        addressLine1: (json["addressLine1"] as String?) ?? "",
        addressResponseDefault: (json["default"] as bool?) ?? false,
        deliveryInstructions: (json["deliveryInstructions"] as String?) ?? "",
        latitude: (json["latitude"] is num
            ? (json["latitude"] as num).toDouble()
            : (json["latitude"] as num?)?.toDouble() ?? 0.0),
        longitude: (json["longitude"] is num
            ? (json["longitude"] as num).toDouble()
            : (json["longitude"] as num?)?.toDouble() ?? 0.0),
        v: (json["__v"] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "addressLine1": addressLine1,
        "default": addressResponseDefault,
        "deliveryInstructions": deliveryInstructions,
        "latitude": latitude,
        "longitude": longitude,
        "__v": v,
      };
}
