import 'package:get/get.dart';
import 'package:intl/intl.dart';

const List<String> _defaultStatuses = [
  'Pending',
  'In Progress',
  'WaitingRequester',
  'Resolved',
  'Closed',
];

const List<String> _defaultPriorities = [
  'Low',
  'Normal',
  'High',
  'Urgent',
];

const List<String> _defaultCategories = [
  'Order',
  'Payment',
  'Account',
  'Delivery',
  'Store',
  'Driver',
  'Technical',
  'Other',
];

const Map<String, String> _statusTranslationKeys = {
  'Pending': 'service_status_pending',
  'In Progress': 'service_status_in_progress',
  'WaitingRequester': 'service_status_waiting_requester',
  'Resolved': 'service_status_resolved',
  'Closed': 'service_status_closed',
};

const Map<String, String> _priorityTranslationKeys = {
  'Low': 'service_priority_low',
  'Normal': 'service_priority_normal',
  'High': 'service_priority_high',
  'Urgent': 'service_priority_urgent',
};

const Map<String, String> _categoryTranslationKeys = {
  'Order': 'service_category_order',
  'Payment': 'service_category_payment',
  'Account': 'service_category_account',
  'Delivery': 'service_category_delivery',
  'Store': 'service_category_store',
  'Driver': 'service_category_driver',
  'Technical': 'service_category_technical',
  'Settlement': 'service_category_settlement',
  'Other': 'service_category_other',
};

class ServiceTicketAttachment {
  final String url;
  final String type;
  final String name;
  final int? size;

  ServiceTicketAttachment({
    required this.url,
    this.type = 'other',
    this.name = '',
    this.size,
  });

  factory ServiceTicketAttachment.fromJson(Map<String, dynamic> json) {
    return ServiceTicketAttachment(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? 'other',
      name: json['name']?.toString() ?? '',
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse(json['size']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'type': type,
        'name': name,
        if (size != null) 'size': size,
      };
}

class ServiceTicketMessage {
  final String authorType;
  final String? authorId;
  final String authorName;
  final String body;
  final bool internal;
  final DateTime createdAt;
  final List<ServiceTicketAttachment> attachments;

  ServiceTicketMessage({
    required this.authorType,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.authorId,
    this.internal = false,
    this.attachments = const [],
  });

  factory ServiceTicketMessage.fromJson(Map<String, dynamic> json) {
    final attachments = (json['attachments'] as List? ?? [])
        .map((e) => ServiceTicketAttachment.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
    return ServiceTicketMessage(
      authorType: json['authorType']?.toString() ?? 'Client',
      authorId: json['authorId']?.toString(),
      authorName: json['authorName']?.toString() ?? '—',
      body: json['body']?.toString() ?? '',
      internal: json['internal'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      attachments: attachments,
    );
  }
}

class ServiceTicket {
  static List<String> get defaultStatuses => _defaultStatuses;
  static List<String> get defaultPriorities => _defaultPriorities;
  static List<String> get defaultCategories => _defaultCategories;

  static String labelForStatus(String value) {
    final key = _statusTranslationKeys[value];
    return key != null ? key.tr : value;
  }

  static String labelForPriority(String value) {
    final key = _priorityTranslationKeys[value];
    return key != null ? key.tr : value;
  }

  static String labelForCategory(String value) {
    final key = _categoryTranslationKeys[value];
    return key != null ? key.tr : value;
  }

  final String id;
  final String code;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final String description;
  final List<String> tags;
  final String sourceApp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? lastMessageAt;
  final List<ServiceTicketMessage> messages;

  ServiceTicket({
    required this.id,
    required this.code,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.description,
    required this.tags,
    required this.sourceApp,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.resolvedAt,
    this.lastMessageAt,
  });

  factory ServiceTicket.fromJson(Map<String, dynamic> json) {
    final messageList = (json['messages'] as List? ?? [])
        .map((e) =>
            ServiceTicketMessage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ServiceTicket(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      priority: json['priority']?.toString() ?? 'Normal',
      status: json['status']?.toString() ?? 'Pending',
      description: json['description']?.toString() ?? '',
      tags: (json['tags'] as List? ?? [])
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      sourceApp: json['sourceApp']?.toString() ?? 'customer',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      messages: messageList,
    );
  }

  String get readableStatus => labelForStatus(status);

  String get readablePriority => labelForPriority(priority);

  String get readableCategory => labelForCategory(category);

  String timeAgo([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    final diff = now.difference(lastMessageAt ?? updatedAt);
    if (diff.inMinutes < 1) return 'time_just_now'.tr;
    if (diff.inHours < 1) {
      return 'time_minutes_ago'
          .trParams({'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time_hours_ago'.trParams({'hours': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'time_days_ago'.trParams({'days': diff.inDays.toString()});
    }
    return DateFormat('dd/MM/yyyy').format(lastMessageAt ?? updatedAt);
  }
}
