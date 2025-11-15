import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/notification_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
        title: ReusableText(
          text: 'Thông báo',
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? TextButton(
                  onPressed: () => controller.markAllAsRead(),
                  child: ReusableText(
                    text: 'Đọc hết',
                    style: appStyle(14, kLightWhite, FontWeight.w500),
                  ),
                )
              : const SizedBox()),
        ],
      ),
      body: BackGroundContainer(
        color: kOffWhite,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimary),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 100.h,
                    color: kGray,
                  ),
                  SizedBox(height: 16.h),
                  ReusableText(
                    text: 'Chưa có thông báo',
                    style: appStyle(16, kGray, FontWeight.w500),
                  ),
                  SizedBox(height: 8.h),
                  ReusableText(
                    text: 'Thông báo về đơn hàng sẽ hiển thị ở đây',
                    style: appStyle(13, kGray, FontWeight.normal),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadNotifications(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                final isRead = notification['isRead'] ?? false;
                final createdAt = DateTime.parse(notification['createdAt']);

                return InkWell(
                  onTap: () {
                    controller.markAsRead(notification['id']);
                    // Navigate to order detail if has orderId
                    if (notification['orderId'] != null) {
                      // Get.to(() => OrderDetailPage(orderId: notification['orderId']));
                    }
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isRead ? kLightWhite : kPrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isRead
                            ? Colors.transparent
                            : kPrimary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification['type'])
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getNotificationIcon(notification['type']),
                            color: _getNotificationColor(notification['type']),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ReusableText(
                                      text:
                                          notification['title'] ?? 'Thông báo',
                                      style: appStyle(
                                        14,
                                        kDark,
                                        isRead
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8.w,
                                      height: 8.h,
                                      decoration: const BoxDecoration(
                                        color: kPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              ReusableText(
                                text: notification['message'] ?? '',
                                style: appStyle(12, kGray, FontWeight.normal),
                              ),
                              SizedBox(height: 6.h),
                              ReusableText(
                                text: timeago.format(createdAt, locale: 'vi'),
                                style: appStyle(11, kGray, FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'order_confirmed':
        return Icons.check_circle_outline;
      case 'order_preparing':
        return Icons.restaurant;
      case 'order_delivering':
        return Icons.local_shipping_outlined;
      case 'order_delivered':
        return Icons.done_all;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'order_confirmed':
        return Colors.blue;
      case 'order_preparing':
        return Colors.orange;
      case 'order_delivering':
        return kPrimary;
      case 'order_delivered':
        return Colors.green;
      case 'order_cancelled':
        return kRed;
      default:
        return kGray;
    }
  }
}
