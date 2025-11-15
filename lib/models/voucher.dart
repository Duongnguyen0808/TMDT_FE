import 'dart:convert';

List<Voucher> voucherFromJson(String str) =>
    List<Voucher>.from(json.decode(str).map((x) => Voucher.fromJson(x)));

String voucherToJson(List<Voucher> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VoucherResponse {
  final bool status;
  final List<Voucher> data;

  VoucherResponse({
    required this.status,
    required this.data,
  });

  factory VoucherResponse.fromJson(Map<String, dynamic> json) =>
      VoucherResponse(
        status: json["status"],
        data: List<Voucher>.from(json["data"].map((x) => Voucher.fromJson(x))),
      );
}

class Voucher {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double? maxDiscount;
  final double minOrderTotal;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int usedCount;
  final List<String> storeIds;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.type,
    required this.value,
    this.maxDiscount,
    required this.minOrderTotal,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    required this.usedCount,
    required this.storeIds,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json["_id"],
      code: json["code"],
      title: json["title"] ?? json["code"],
      description: json["description"],
      type: json["type"],
      value: (json["value"] as num).toDouble(),
      maxDiscount: json["maxDiscount"] != null
          ? (json["maxDiscount"] as num).toDouble()
          : null,
      minOrderTotal: json["minOrderTotal"] != null
          ? (json["minOrderTotal"] as num).toDouble()
          : 0.0,
      validFrom:
          json["validFrom"] != null ? DateTime.parse(json["validFrom"]) : null,
      validUntil: json["validUntil"] != null
          ? DateTime.parse(json["validUntil"])
          : null,
      usageLimit: json["usageLimit"],
      usedCount: json["usedCount"] ?? 0,
      storeIds: json["storeIds"] != null
          ? List<String>.from(json["storeIds"].map((x) => x.toString()))
          : [],
      isActive: json["isActive"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "code": code,
        "title": title,
        "description": description,
        "type": type,
        "value": value,
        "maxDiscount": maxDiscount,
        "minOrderTotal": minOrderTotal,
        "validFrom": validFrom?.toIso8601String(),
        "validUntil": validUntil?.toIso8601String(),
        "usageLimit": usageLimit,
        "usedCount": usedCount,
        "storeIds": storeIds,
        "isActive": isActive,
      };

  // Calculate discount amount for given order total
  double calculateDiscount(double orderTotal) {
    if (!isActive || orderTotal < minOrderTotal) return 0.0;

    double discount = 0.0;
    if (type == 'percentage') {
      discount = (orderTotal * value) / 100;
      if (maxDiscount != null) {
        discount = discount > maxDiscount! ? maxDiscount! : discount;
      }
    } else if (type == 'fixed') {
      discount = value > orderTotal ? orderTotal : value;
    }

    return discount.floorToDouble();
  }

  // Get formatted discount text for display
  String getDiscountText() {
    if (type == 'percentage') {
      String text = 'Giảm ${value.toInt()}%';
      if (maxDiscount != null) {
        text += ' (Tối đa ${maxDiscount!.toInt()}đ)';
      }
      return text;
    } else {
      return 'Giảm ${value.toInt()}đ';
    }
  }

  // Check if voucher is still valid
  bool isValidNow() {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;
    return true;
  }
}
