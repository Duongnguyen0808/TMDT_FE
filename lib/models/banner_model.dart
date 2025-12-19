import 'dart:convert';

List<BannerModel> bannerModelFromJson(String str) => List<BannerModel>.from(
    (json.decode(str) as List<dynamic>).map((x) => BannerModel.fromJson(x)));

class BannerModel {
  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.description,
    this.category,
    this.redirectUrl,
    this.ctaText,
    this.isActive = true,
    this.sortOrder,
    this.startAt,
    this.endAt,
    this.actionType,
    this.actionValue,
    List<String>? productIds,
    List<BannerProduct>? linkedProducts,
  })  : productIds = productIds ?? const <String>[],
        linkedProducts = linkedProducts ?? const <BannerProduct>[];

  final String id;
  final String title;
  final String imageUrl;
  final String? subtitle;
  final String? description;
  final String? category;
  final String? redirectUrl;
  final String? ctaText;
  final bool isActive;
  final int? sortOrder;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? actionType;
  final String? actionValue;
  final List<String> productIds;
  final List<BannerProduct> linkedProducts;

  bool get hasLinkedProducts => linkedProducts.isNotEmpty;

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        imageUrl: (json['imageUrl'] ?? '').toString(),
        subtitle: json['subtitle']?.toString(),
        description: json['description']?.toString(),
        category: json['category']?.toString(),
        redirectUrl: json['redirectUrl']?.toString(),
        ctaText: json['ctaText']?.toString(),
        isActive: json['isActive'] is bool
            ? json['isActive'] as bool
            : json['isActive'] == null
                ? true
                : json['isActive'].toString() != 'false',
        sortOrder: json['sortOrder'] is int
            ? json['sortOrder'] as int
            : int.tryParse(json['sortOrder']?.toString() ?? ''),
        startAt: json['startAt'] != null
            ? DateTime.tryParse(json['startAt'].toString())
            : null,
        endAt: json['endAt'] != null
            ? DateTime.tryParse(json['endAt'].toString())
            : null,
        actionType: json['actionType']?.toString(),
        actionValue: json['actionValue']?.toString(),
        productIds: (json['productIds'] as List?)
                ?.map((e) => e.toString())
                .where((element) => element.isNotEmpty)
                .toList() ??
            const <String>[],
        linkedProducts: (json['linkedProducts'] as List?)
                ?.map((item) => BannerProduct.fromJson(item))
                .toList() ??
            const <BannerProduct>[],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'subtitle': subtitle,
        'description': description,
        'category': category,
        'redirectUrl': redirectUrl,
        'ctaText': ctaText,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'startAt': startAt?.toIso8601String(),
        'endAt': endAt?.toIso8601String(),
        'actionType': actionType,
        'actionValue': actionValue,
        'productIds': productIds,
        'linkedProducts': linkedProducts.map((p) => p.toJson()).toList(),
      };
}

class BannerProduct {
  BannerProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.stock,
    this.slug,
  });

  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final int? stock;
  final String? slug;

  factory BannerProduct.fromJson(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return BannerProduct(
        id: data?.toString() ?? '',
        title: '',
        price: 0,
        imageUrl: '',
      );
    }
    return BannerProduct(
      id: (data['_id'] ?? data['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      price: _parsePrice(data['price']),
      imageUrl: _resolveImageUrl(data['imageUrl']),
      stock: _parseInt(data['stock']),
      slug: data['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'imageUrl': imageUrl,
        if (stock != null) 'stock': stock,
        if (slug != null) 'slug': slug,
      };

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String _resolveImageUrl(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return value.toString();
  }
}
