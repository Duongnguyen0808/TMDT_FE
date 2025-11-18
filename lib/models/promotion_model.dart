class PromotionModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? deepLink;
  final Map<String, dynamic> data;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String status;
  final int successCount;
  final int failureCount;
  final String? variant;

  bool get isActive {
    final now = DateTime.now();
    final started = startsAt.isBefore(now) || startsAt.isAtSameMomentAs(now);
    final notEnded = endsAt == null || endsAt!.isAfter(now);
    return started && notEnded && status == 'sent';
  }

  PromotionModel({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.deepLink,
    required this.data,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.successCount,
    required this.failureCount,
    required this.variant,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
        id: json['_id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        imageUrl: json['imageUrl'],
        deepLink: json['deepLink'],
        data: (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : <String, dynamic>{},
        startsAt: DateTime.tryParse(json['startsAt'] ?? '') ?? DateTime.now(),
        endsAt:
            json['endsAt'] != null ? DateTime.tryParse(json['endsAt']) : null,
        status: json['status'] ?? 'scheduled',
        successCount: json['successCount'] ?? 0,
        failureCount: json['failureCount'] ?? 0,
        variant: json['variant'],
      );
}
