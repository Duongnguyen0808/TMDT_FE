import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/views/orders/user_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientOrderTile extends StatefulWidget {
  const ClientOrderTile({
    super.key,
    required this.appliances,
    this.color,
    this.fullOrder,
    this.onCancelled,
  });

  final OrderItem appliances;
  final Color? color;
  final ClientOrders? fullOrder;
  final VoidCallback? onCancelled;

  @override
  State<ClientOrderTile> createState() => _ClientOrderTileState();
}

class _ClientOrderTileState extends State<ClientOrderTile> {
  String _getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xử lý';
      case 'Preparing':
        return 'Đang chuẩn bị';
      case 'Delivered':
        return 'Đã giao';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return kGray;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getEstimatedDeliveryTime(DateTime orderTime, String status) {
    if (status == 'Delivered') {
      return 'Đã giao';
    }
    if (status == 'Cancelled') {
      return 'Đã hủy';
    }
    // Ước tính giao sau 30-60 phút
    final estimatedTime = orderTime.add(const Duration(minutes: 45));
    return DateFormat('HH:mm').format(estimatedTime);
  }

  Future<void> _confirmReceived(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: ReusableText(
          text: 'Xác nhận đã nhận hàng',
          style: appStyle(16, kDark, FontWeight.w600),
        ),
        content: ReusableText(
          text:
              'Bạn đã nhận được hàng và xác nhận thanh toán cho đơn hàng này?',
          style: appStyle(13, kGray, FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ReusableText(
              text: 'Chưa',
              style: appStyle(13, kGray, FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: ReusableText(
              text: 'Xác nhận',
              style: appStyle(13, kWhite, FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final box = GetStorage();
        final token = box.read('token');

        final response = await http.put(
          Uri.parse(
              '$appBaseUrl/api/orders/${widget.fullOrder!.id}/confirm-received'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          Get.snackbar(
            'Thành công',
            'Đã xác nhận nhận hàng và hoàn tất thanh toán',
            backgroundColor: kPrimary,
            colorText: kWhite,
            icon: const Icon(Icons.check_circle, color: kWhite),
          );
          widget.onCancelled?.call(); // Refresh list
        } else {
          final error = jsonDecode(response.body);
          Get.snackbar(
            'Lỗi',
            error['message'] ?? 'Không thể xác nhận nhận hàng',
            backgroundColor: kRed,
            colorText: kWhite,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Đã xảy ra lỗi: $e',
          backgroundColor: kRed,
          colorText: kWhite,
        );
      }
    }
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ReusableText(
                text: 'Hủy đơn hàng',
                style: appStyle(18, kDark, FontWeight.w600),
              ),
              SizedBox(height: 12.h),

              // Description
              ReusableText(
                text: 'Vui lòng cho biết lý do hủy đơn:',
                style: appStyle(13, kGray, FontWeight.w400),
              ),
              SizedBox(height: 16.h),

              // TextField
              Container(
                decoration: BoxDecoration(
                  color: kOffWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: kGrayLight, width: 1),
                ),
                child: TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do hủy...',
                    hintStyle: appStyle(13, kGray, FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  style: appStyle(13, kDark, FontWeight.w400),
                  maxLines: 4,
                  minLines: 4,
                ),
              ),
              SizedBox(height: 20.h),

              // Buttons
              Row(
                children: [
                  // Nút Không
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGray,
                        side: BorderSide(color: kGrayLight, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: ReusableText(
                        text: 'Không',
                        style: appStyle(14, kGray, FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Nút Xác nhận
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Lỗi',
                            'Vui lòng nhập lý do hủy đơn',
                            backgroundColor: kRed,
                            colorText: kWhite,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: EdgeInsets.all(12.w),
                            borderRadius: 8.r,
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRed,
                        foregroundColor: kWhite,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: ReusableText(
                        text: 'Xác nhận hủy',
                        style: appStyle(14, kWhite, FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && widget.fullOrder != null) {
      try {
        final box = GetStorage();
        final token = box.read('token');

        final response = await http.put(
          Uri.parse('$appBaseUrl/api/orders/${widget.fullOrder!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'orderStatus': 'Cancelled',
            'cancellationReason': reasonController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          Get.snackbar(
            'Thành công',
            'Đã hủy đơn hàng',
            backgroundColor: kPrimary,
            colorText: kWhite,
          );
          widget.onCancelled?.call();
        } else {
          final error = jsonDecode(response.body);
          Get.snackbar(
            'Lỗi',
            error['message'] ?? 'Không thể hủy đơn hàng',
            backgroundColor: kRed,
            colorText: kWhite,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Lỗi',
          'Đã xảy ra lỗi: $e',
          backgroundColor: kRed,
          colorText: kWhite,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderStatus = widget.fullOrder?.orderStatus ?? 'Pending';
    final statusColor = _getStatusColor(orderStatus);
    final statusText = _getStatusText(orderStatus);

    return GestureDetector(
      onTap: () {
        if (widget.fullOrder != null) {
          Get.to(() => UserOrderDetailPage(order: widget.fullOrder!));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: kGrayLight.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã đơn và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, size: 16.sp, color: kPrimary),
                    SizedBox(width: 4.w),
                    ReusableText(
                      text:
                          '#TM${widget.fullOrder?.id.substring(widget.fullOrder!.id.length - 6).toUpperCase() ?? 'N/A'}',
                      style: appStyle(13, kDark, FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: ReusableText(
                    text: statusText,
                    style: appStyle(11, statusColor, FontWeight.w600),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Thông tin sản phẩm
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                    width: 60.w,
                    height: 60.h,
                    child: Image.network(
                      widget.appliances.appliancesId.imageUrl.isNotEmpty
                          ? widget.appliances.appliancesId.imageUrl[0]
                          : "",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: kGrayLight,
                          child: Icon(Icons.image_not_supported, size: 24.sp),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableText(
                        text: widget.appliances.appliancesId.title,
                        style: appStyle(13, kDark, FontWeight.w500),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 12.sp, color: kGray),
                          SizedBox(width: 4.w),
                          ReusableText(
                            text: 'Số lượng: ${widget.appliances.quantity}',
                            style: appStyle(11, kGray, FontWeight.w400),
                          ),
                        ],
                      ),
                      if (widget.fullOrder != null &&
                          widget.fullOrder!.orderItems.length > 1) ...[
                        SizedBox(height: 2.h),
                        ReusableText(
                          text:
                              '+${widget.fullOrder!.orderItems.length - 1} sản phẩm khác',
                          style: appStyle(10, kSecondary, FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),

                // Giá
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ReusableText(
                      text: usdToVndText((widget.fullOrder?.orderTotal ?? 0) -
                          (widget.fullOrder?.discountAmount ?? 0) +
                          (widget.fullOrder?.deliveryFee ?? 0)),
                      style: appStyle(13, kPrimary, FontWeight.bold),
                    ),
                    if (widget.fullOrder != null) ...[
                      SizedBox(height: 2.h),
                      ReusableText(
                        text: widget.fullOrder!.paymentMethod == 'COD'
                            ? 'COD'
                            : 'VNPay',
                        style: appStyle(9, kGray, FontWeight.w400),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            SizedBox(height: 10.h),
            Divider(height: 1, color: kGrayLight),
            SizedBox(height: 8.h),

            // Footer: Thời gian
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ngày đặt
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12.sp, color: kGray),
                    SizedBox(width: 4.w),
                    ReusableText(
                      text: widget.fullOrder != null
                          ? _formatDate(widget.fullOrder!.createdAt)
                          : '',
                      style: appStyle(10, kGray, FontWeight.w400),
                    ),
                  ],
                ),

                // Dự kiến giao
                if (orderStatus != 'Delivered' && orderStatus != 'Cancelled')
                  Row(
                    children: [
                      Icon(Icons.delivery_dining,
                          size: 12.sp, color: kSecondary),
                      SizedBox(width: 4.w),
                      ReusableText(
                        text:
                            'Dự kiến: ${widget.fullOrder != null ? _getEstimatedDeliveryTime(widget.fullOrder!.createdAt, orderStatus) : ''}',
                        style: appStyle(10, kSecondary, FontWeight.w500),
                      ),
                    ],
                  ),
              ],
            ),

            // Nút hủy đơn hàng (chỉ hiện khi Pending)
            if (orderStatus == 'Pending') ...[
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelOrder(context),
                  icon: Icon(Icons.cancel_outlined, size: 16.sp),
                  label: const Text('Hủy đơn hàng'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: BorderSide(color: kRed, width: 1),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],

            // Nút xác nhận đã nhận hàng (chỉ hiện khi Delivered và chưa thanh toán)
            if (orderStatus == 'Delivered' &&
                widget.fullOrder?.paymentStatus == 'Pending') ...[
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmReceived(context),
                  icon: Icon(Icons.check_circle_outline, size: 16.sp),
                  label: const Text('Đã nhận hàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: kWhite,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
