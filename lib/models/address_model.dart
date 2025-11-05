import 'dart:convert';

AddressModel addressModelFromJson(String str) =>
    AddressModel.fromJson(json.decode(str));

String addressModelToJson(AddressModel data) => json.encode(data.toJson());

class AddressModel {
  final String addressLine1;
  final bool addressModelDefault;
  final String deliveryInstructions;
  final double latitude;
  final double longitude;

  AddressModel({
    required this.addressLine1,
    required this.addressModelDefault,
    required this.deliveryInstructions,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        addressLine1: (json["addressLine1"] as String?) ?? "",
        addressModelDefault: (json["default"] as bool?) ?? false,
        deliveryInstructions: (json["deliveryInstructions"] as String?) ?? "",
        latitude: (json["latitude"] is num
            ? (json["latitude"] as num).toDouble()
            : (json["latitude"] as num?)?.toDouble() ?? 0.0),
        longitude: (json["longitude"] is num
            ? (json["longitude"] as num).toDouble()
            : (json["longitude"] as num?)?.toDouble() ?? 0.0),
      );

  Map<String, dynamic> toJson() => {
        "addressLine1": addressLine1,
        "default": addressModelDefault,
        "deliveryInstructions": deliveryInstructions,
        "latitude": latitude,
        "longitude": longitude,
      };
}
