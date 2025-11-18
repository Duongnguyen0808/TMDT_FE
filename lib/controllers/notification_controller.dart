import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:appliances_flutter/constants/constants.dart';

class NotificationController extends GetxController {
  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _loadUnreadCount();
  }

  Future<void> loadNotifications() async {
    // Mock data for now - replace with real API when backend is ready
    await Future.delayed(const Duration(milliseconds: 500));

    // Get user orders to create notifications
    try {
      // Use the same key as login_controller writes
      String? accessToken = box.read('token');
      final url = Uri.parse('$appBaseUrl/api/orders');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null && accessToken.isNotEmpty)
            'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> orders = jsonDecode(response.body);

        // Create notifications from orders
        List<Map<String, dynamic>> tempNotifications = [];

        for (var order in orders) {
          tempNotifications.add({
            'id': order['_id'],
            'orderId': order['_id'],
            'type': _getNotificationType(order['orderStatus']),
            'title': _getNotificationTitle(order['orderStatus']),
            'message':
                _getNotificationMessage(order['orderStatus'], order['_id']),
            'isRead': false,
            'createdAt': order['updatedAt'] ?? order['createdAt'],
          });
        }

        // Sort by date desc
        tempNotifications.sort((a, b) => DateTime.parse(b['createdAt'])
            .compareTo(DateTime.parse(a['createdAt'])));

        notifications.value = tempNotifications;
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  String _getNotificationType(String orderStatus) {
    switch (orderStatus) {
      case 'Pending':
        return 'order_confirmed';
      case 'Preparing':
        return 'order_preparing';
      case 'Delivered':
        return 'order_delivered';
      case 'Cancelled':
        return 'order_cancelled';
      default:
        return 'order_update';
    }
  }

  String _getNotificationTitle(String orderStatus) {
    switch (orderStatus) {
      case 'Pending':
        return 'Đơn hàng đã được xác nhận';
      case 'Preparing':
        return 'Đơn hàng đang được chuẩn bị';
      case 'Delivering':
        return 'Đơn hàng đang được giao';
      case 'Delivered':
        return 'Đơn hàng đã giao thành công';
      case 'Cancelled':
        return 'Đơn hàng đã bị hủy';
      default:
        return 'Cập nhật đơn hàng';
    }
  }

  String _getNotificationMessage(String orderStatus, String orderId) {
    final shortId = orderId.substring(orderId.length - 6);
    switch (orderStatus) {
      case 'Pending':
        return 'Đơn hàng #$shortId đã được xác nhận và đang chờ xử lý';
      case 'Preparing':
        return 'Đơn hàng #$shortId đang được chuẩn bị';
      case 'Delivering':
        return 'Đơn hàng #$shortId đang trên đường giao đến bạn';
      case 'Delivered':
        return 'Đơn hàng #$shortId đã được giao thành công. Cảm ơn bạn!';
      case 'Cancelled':
        return 'Đơn hàng #$shortId đã bị hủy';
      default:
        return 'Cập nhật trạng thái đơn hàng #$shortId';
    }
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1 && !(notifications[index]['isRead'] ?? false)) {
      notifications[index]['isRead'] = true;
      notifications.refresh();
      _updateUnreadCount();
      _saveUnreadCount();
    }
  }

  void markAllAsRead() {
    for (var notification in notifications) {
      notification['isRead'] = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    _saveUnreadCount();

    Get.snackbar(
      'Thành công',
      'Đã đánh dấu tất cả là đã đọc',
      backgroundColor: kPrimary,
      colorText: kLightWhite,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateUnreadCount() {
    unreadCount.value =
        notifications.where((n) => !(n['isRead'] ?? false)).length;
    _saveUnreadCount();
  }

  void _saveUnreadCount() {
    box.write('unreadNotificationCount', unreadCount.value);
  }

  void _loadUnreadCount() {
    unreadCount.value = box.read('unreadNotificationCount') ?? 0;
  }
}
