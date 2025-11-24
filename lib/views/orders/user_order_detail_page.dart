import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/services/vietmap_service.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const Set<String> _orderCancellableStatuses = {
  'Pending',
  'Preparing',
  'ReadyForPickup',
  'WaitingShipper',
};

class UserOrderDetailPage extends StatefulWidget {
  final ClientOrders order;

  const UserOrderDetailPage({super.key, required this.order});

  @override
  State<UserOrderDetailPage> createState() => _UserOrderDetailPageState();
}

class _UserOrderDetailPageState extends State<UserOrderDetailPage> {
  bool _isCancelling = false;
  bool _isConfirming = false;
  bool _isRequestingReturn = false;
  String? _localReturnStatus; // Tracks return state after user action
  DistanceTime? _distanceTime;
  bool _isLoadingDistance = true;

  @override
  void initState() {
    super.initState();
    _loadDistanceAndTime();
    _localReturnStatus = widget.order.returnStatus;
  }

  Future<void> _confirmReceived() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      final box = GetStorage();
      final accessToken = box.read('token');

      final response = await http.put(
        Uri.parse('$appBaseUrl/api/orders/${widget.order.id}/confirm-received'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Thành công",
          "Đã xác nhận nhận hàng và hoàn tất thanh toán",
          backgroundColor: kPrimary,
          colorText: kWhite,
          icon: const Icon(Icons.check_circle, color: kWhite),
        );

        // Quay lại và refresh
        Get.back(result: true);
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          "Lỗi",
          errorData['message'] ?? "Không thể xác nhận nhận hàng",
          backgroundColor: kRed,
          colorText: kWhite,
          icon: const Icon(Icons.error, color: kWhite),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi: $e",
        backgroundColor: kRed,
        colorText: kWhite,
        icon: const Icon(Icons.error, color: kWhite),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  Future<void> _loadDistanceAndTime() async {
    if (widget.order.storeCoords.isEmpty ||
        widget.order.storeCoords.length < 2 ||
        widget.order.recipientCoords.isEmpty ||
        widget.order.recipientCoords.length < 2) {
      setState(() {
        _isLoadingDistance = false;
      });
      return;
    }

    try {
      final result = await VietmapService.calculateDistance(
        storeLat: widget.order.storeCoords[1],
        storeLng: widget.order.storeCoords[0],
        customerLat: widget.order.recipientCoords[1],
        customerLng: widget.order.recipientCoords[0],
        pricePerKm: 5000, // Giá mỗi km
      );

      setState(() {
        _distanceTime = result;
        _isLoadingDistance = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDistance = false;
      });
    }
  }

  String _formatTime(double hours) {
    if (hours < 1) {
      // Dưới 1 giờ, hiển thị phút
      final minutes = (hours * 60).round();
      return '$minutes phút';
    } else if (hours < 24) {
      // Dưới 24 giờ, hiển thị giờ + phút
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      return m > 0 ? '$h giờ $m phút' : '$h giờ';
    } else {
      // Trên 24 giờ, hiển thị ngày + giờ
      final days = (hours / 24).floor();
      final remainingHours = (hours % 24).round();
      return remainingHours > 0
          ? '$days ngày $remainingHours giờ'
          : '$days ngày';
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool isCancelled = order.orderStatus == 'Cancelled';
    final bool canCancel =
        _orderCancellableStatuses.contains(order.orderStatus);
    final String? logisticStatus = order.logisticStatus;

    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
        ),
        title: ReusableText(
          text: "Chi tiết đơn hàng",
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
      ),
      body: BackGroundContainer(
        color: kLightWhite,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color:
                      _getStatusColor(order.orderStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _getStatusColor(order.orderStatus),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(order.orderStatus),
                      color: _getStatusColor(order.orderStatus),
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReusableText(
                            text: _getStatusText(order.orderStatus),
                            style: appStyle(
                              16,
                              _getStatusColor(order.orderStatus),
                              FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          ReusableText(
                            text: _getStatusDescription(order.orderStatus),
                            style: appStyle(12, kGray, FontWeight.w400),
                          ),
                          if (logisticStatus != null &&
                              logisticStatus.isNotEmpty &&
                              logisticStatus != order.orderStatus) ...[
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: _getStatusColor(logisticStatus)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: ReusableText(
                                text:
                                    'Logistics: ${_getStatusText(logisticStatus)}',
                                style: appStyle(
                                  11,
                                  _getStatusColor(logisticStatus),
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              if (!isCancelled) ...[
                _buildPickupTimelineCard(order),
                SizedBox(height: 16.h),
              ],

              // Order Info Card
              _buildInfoCard(
                title: "Thông tin đơn hàng",
                children: [
                  _buildInfoRow("Mã đơn hàng",
                      "#TM${order.id.substring(order.id.length - 6).toUpperCase()}"),
                  _buildInfoRow(
                    "Thời gian đặt",
                    DateFormat('dd/MM/yyyy - HH:mm').format(order.createdAt),
                  ),
                  _buildInfoRow(
                      "Phương thức thanh toán",
                      order.paymentMethod == 'COD'
                          ? 'Tiền mặt'
                          : order.paymentMethod),
                  _buildInfoRow(
                    "Trạng thái thanh toán",
                    order.paymentStatus == 'Completed'
                        ? 'Đã thanh toán'
                        : order.paymentStatus == 'Pending'
                            ? 'Chờ thanh toán'
                            : 'Thất bại',
                    valueColor:
                        order.paymentStatus == "Completed" ? kPrimary : kRed,
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Distance and Time Card (from Vietmap)
              if (_distanceTime != null)
                _buildInfoCard(
                  title: "Khoảng cách & Thời gian",
                  children: [
                    Row(
                      children: [
                        Icon(Icons.straighten, color: kPrimary, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildInfoRow(
                            "Khoảng cách",
                            "${_distanceTime!.distance.toStringAsFixed(2)} km",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: kSecondary, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildInfoRow(
                            "Thời gian ước tính",
                            _formatTime(_distanceTime!.time),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else if (_isLoadingDistance)
                Container(
                  padding: EdgeInsets.all(16.w),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(kPrimary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ReusableText(
                        text: 'Đang tính khoảng cách...',
                        style: appStyle(12, kGray, FontWeight.w400),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              // Delivery Address Card
              _buildInfoCard(
                title: "Địa chỉ giao hàng",
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: kPrimary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ReusableText(
                          text: order.deliveryAddress,
                          style: appStyle(13, kDark, FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Order Items Card
              _buildInfoCard(
                title: "Sản phẩm đã đặt",
                children: [
                  ...order.orderItems.map((item) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: kOffWhite,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              item.appliancesId.imageUrl.isNotEmpty
                                  ? item.appliancesId.imageUrl[0]
                                  : "",
                              width: 60.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60.w,
                                  height: 60.h,
                                  color: kGrayLight,
                                  child: Icon(Icons.image_not_supported,
                                      size: 30.sp),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReusableText(
                                  text: item.appliancesId.title,
                                  style: appStyle(14, kDark, FontWeight.w600),
                                ),
                                SizedBox(height: 4.h),
                                ReusableText(
                                  text: "Số lượng: ${item.quantity}",
                                  style: appStyle(12, kGray, FontWeight.w400),
                                ),
                                if (item.additives.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Wrap(
                                    spacing: 4.w,
                                    runSpacing: 4.h,
                                    children: item.additives.map((additive) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kSecondaryLight,
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: ReusableText(
                                          text: additive,
                                          style: appStyle(
                                              10, kGray, FontWeight.w400),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          ReusableText(
                            text: usdToVndText(item.price * item.quantity),
                            style: appStyle(14, kPrimary, FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

              SizedBox(height: 16.h),

              // Payment Summary Card
              _buildInfoCard(
                title: "Chi tiết thanh toán",
                children: [
                  _buildInfoRow(
                      "Tổng đơn hàng", usdToVndText(order.orderTotal)),
                  if (order.discountAmount != null &&
                      order.discountAmount! > 0) ...[
                    _buildInfoRow(
                      "Giảm giá (${order.promoCode ?? 'Voucher'})",
                      "- ${usdToVndText(order.discountAmount!)}",
                      valueColor: kSecondary,
                    ),
                  ],
                  _buildInfoRow(
                      "Phí vận chuyển", usdToVndText(order.deliveryFee)),
                  Divider(height: 20.h, thickness: 1),
                  _buildInfoRow(
                    "Tổng cộng",
                    usdToVndText(order.orderTotal -
                        (order.discountAmount ?? 0) +
                        order.deliveryFee),
                    titleStyle: appStyle(15, kDark, FontWeight.bold),
                    valueStyle: appStyle(16, kPrimary, FontWeight.bold),
                  ),
                ],
              ),

              // Cancellation Reason (if cancelled)
              if (isCancelled) ...[
                SizedBox(height: 16.h),
                _buildInfoCard(
                  title: "Lý do hủy đơn",
                  children: [
                    ReusableText(
                      text:
                          "Lý do hủy: ${order.cancellationReason ?? 'Không rõ'}",
                      style: appStyle(13, kRed, FontWeight.w400),
                    ),
                    if (order.cancelledAt != null) ...[
                      SizedBox(height: 4.h),
                      ReusableText(
                        text:
                            'Thời gian hủy: ${DateFormat('dd/MM/yyyy - HH:mm').format(order.cancelledAt!)}',
                        style: appStyle(12, kGray, FontWeight.w400),
                      ),
                    ],
                  ],
                ),
              ],

              SizedBox(height: 20.h),

              // Cancel Button (for cancellable statuses)
              if (!isCancelled && canCancel)
                CustomButton(
                  onTap: _isCancelling ? () {} : _showCancelDialog,
                  btnColor: kRed,
                  btnHeight: 45.h,
                  text: _isCancelling ? "Đang xử lý..." : "Hủy đơn hàng",
                ),

              // Confirm Received Button (only for Delivered orders with Pending payment)
              if (order.orderStatus == 'Delivered' &&
                  order.paymentStatus == 'Pending')
                CustomButton(
                  onTap: _isConfirming ? () {} : _confirmReceived,
                  btnColor: kPrimary,
                  btnHeight: 45.h,
                  text: _isConfirming ? "Đang xử lý..." : "Đã nhận hàng",
                ),

              // Return Request Button (for Delivered orders)
              if (order.orderStatus == 'Delivered' &&
                  (_localReturnStatus == null ||
                      _localReturnStatus == 'None' ||
                      _localReturnStatus!.isEmpty))
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: CustomButton(
                    onTap: _isRequestingReturn ? () {} : _showReturnDialog,
                    btnColor: kSecondary,
                    btnHeight: 45.h,
                    text: _isRequestingReturn
                        ? "Đang gửi yêu cầu..."
                        : "Yêu cầu trả hàng/Hoàn tiền",
                  ),
                ),

              // Return/Refund Status Panel
              if (order.orderStatus == 'Delivered' &&
                  (_localReturnStatus != null &&
                      _localReturnStatus != 'None' &&
                      _localReturnStatus!.isNotEmpty))
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: _buildInfoCard(
                    title: 'Trả hàng/Hoàn tiền',
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_return,
                              color: kGray, size: 18.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ReusableText(
                              text: _mapReturnStatus(_localReturnStatus!),
                              style: appStyle(13, kDark, FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      if (_localReturnStatus == 'Rejected') ...[
                        SizedBox(height: 6.h),
                        ReusableText(
                          text:
                              'Yêu cầu bị từ chối. Nếu có nhầm lẫn, vui lòng liên hệ cửa hàng để được hỗ trợ.',
                          style: appStyle(12, kGray, FontWeight.w400),
                        ),
                      ],
                      if (widget.order.returnReason != null &&
                          widget.order.returnReason!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        ReusableText(
                          text: 'Lý do: ${widget.order.returnReason}',
                          style: appStyle(12, kGray, FontWeight.w400),
                        ),
                      ],
                      if (_localReturnStatus == 'Refunded' &&
                          widget.order.refundAmount != null) ...[
                        SizedBox(height: 6.h),
                        ReusableText(
                          text:
                              'Đã hoàn: ${widget.order.refundAmount!.toStringAsFixed(0)}đ',
                          style: appStyle(12, kGray, FontWeight.w400),
                        ),
                      ],
                    ],
                  ),
                ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: kGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableText(
            text: title,
            style: appStyle(16, kDark, FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value, {
    TextStyle? titleStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ReusableText(
              text: title,
              style: titleStyle ?? appStyle(13, kGray, FontWeight.w400),
            ),
          ),
          Expanded(
            flex: 3,
            child: ReusableText(
              text: value,
              style: valueStyle ??
                  appStyle(13, valueColor ?? kDark, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTimelineCard(ClientOrders order) {
    final steps = _buildTimelineSteps(order);
    if (steps.isEmpty) return const SizedBox.shrink();
    return _buildInfoCard(
      title: "Tiến trình lấy & giao hàng",
      children: steps
          .asMap()
          .entries
          .map((entry) => _buildTimelineRow(
                entry.value,
                entry.key == steps.length - 1,
              ))
          .toList(),
    );
  }

  List<_TimelineStepData> _buildTimelineSteps(ClientOrders order) {
    final status = order.orderStatus;
    final bool isCancelled = status == 'Cancelled';
    if (isCancelled) return [];

    final bool preparingStarted = status != 'Pending' && status != 'Cancelled';
    final bool readyForPickup = order.pickupReadyAt != null ||
        status == 'ReadyForPickup' ||
        status == 'WaitingShipper' ||
        status == 'PickedUp' ||
        status == 'Delivering' ||
        status == 'Delivered';
    final bool shipperAssigned = order.pickupAssignedAt != null ||
        status == 'WaitingShipper' ||
        status == 'PickedUp' ||
        status == 'Delivering' ||
        status == 'Delivered';
    final bool pickedUp = order.pickupConfirmedAt != null ||
        status == 'PickedUp' ||
        status == 'Delivering' ||
        status == 'Delivered';
    final bool delivering = status == 'Delivering' || status == 'Delivered';
    final bool delivered = status == 'Delivered';

    return [
      _TimelineStepData(
        title: 'Đặt hàng thành công',
        description: 'Chúng tôi đã nhận đơn của bạn',
        timestamp: order.createdAt,
        completed: true,
      ),
      _TimelineStepData(
        title: 'Cửa hàng chuẩn bị',
        description: order.shopReadyBy != null
            ? 'Dự kiến xong trước ${order.shopReadyBy}'
            : 'Cửa hàng đang chế biến món ăn',
        timestamp: preparingStarted ? order.createdAt : null,
        completed: preparingStarted,
      ),
      _TimelineStepData(
        title: 'Sẵn sàng bàn giao',
        description: order.pickupCode != null && order.pickupCode!.isNotEmpty
            ? 'Mã bàn giao: ${order.pickupCode}'
            : 'Chờ cửa hàng xác nhận mã bàn giao',
        timestamp: order.pickupReadyAt,
        completed: readyForPickup,
      ),
      _TimelineStepData(
        title: 'Đã gán shipper',
        description: order.shipperPickupBy != null
            ? 'Tài xế nhận trước ${order.shipperPickupBy}'
            : 'Hệ thống đang tìm tài xế gần nhất',
        timestamp: order.pickupAssignedAt,
        completed: shipperAssigned,
      ),
      _TimelineStepData(
        title: 'Shipper nhận hàng',
        description:
            order.pickupNotes ?? 'Tài xế đã xác nhận mã và rời cửa hàng',
        timestamp: order.pickupConfirmedAt ?? order.pickupCheckinAt,
        completed: pickedUp,
      ),
      _TimelineStepData(
        title: 'Đang giao hàng',
        description: 'Đơn hàng đang trên đường đến bạn',
        timestamp: delivering ? order.pickupConfirmedAt : null,
        completed: delivering,
      ),
      _TimelineStepData(
        title: 'Giao thành công',
        description: 'Hãy giúp chúng tôi xác nhận khi đã nhận đủ hàng',
        timestamp: delivered ? order.updatedAt : null,
        completed: delivered,
      ),
    ];
  }

  Widget _buildTimelineRow(_TimelineStepData step, bool isLast) {
    final Color indicatorColor =
        step.completed ? kPrimary : kGray.withValues(alpha: 0.4);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.completed ? indicatorColor : kWhite,
                  border: Border.all(color: indicatorColor, width: 2),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40.h,
                  color: indicatorColor.withValues(alpha: 0.3),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: step.title,
                  style: appStyle(13, kDark, FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                ReusableText(
                  text: step.description,
                  style: appStyle(12, kGray, FontWeight.w400),
                ),
                SizedBox(height: 2.h),
                ReusableText(
                  text: _formatTimelineTime(step.timestamp),
                  style: appStyle(11, kGray, FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimelineTime(DateTime? time) {
    if (time == null) return 'Đang cập nhật';
    return DateFormat('dd/MM - HH:mm').format(time);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'ReadyForPickup':
        return Colors.teal;
      case 'WaitingShipper':
        return Colors.deepOrange;
      case 'PickedUp':
        return Colors.indigo;
      case 'Delivering':
        return Colors.purple;
      case 'Delivered':
        return kPrimary;
      case 'Cancelled':
        return kRed;
      default:
        return kGray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'Preparing':
        return Icons.restaurant;
      case 'ReadyForPickup':
        return Icons.store_mall_directory;
      case 'WaitingShipper':
        return Icons.delivery_dining;
      case 'PickedUp':
        return Icons.inventory_2;
      case 'Delivering':
        return Icons.local_shipping;
      case 'Delivered':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xác nhận';
      case 'Preparing':
        return 'Đang chuẩn bị';
      case 'ReadyForPickup':
        return 'Sẵn sàng lấy hàng';
      case 'WaitingShipper':
        return 'Đang gán shipper';
      case 'PickedUp':
        return 'Shipper đã nhận';
      case 'Delivering':
        return 'Đang giao hàng';
      case 'Delivered':
        return 'Đã giao hàng';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Pending':
        return 'Đơn hàng đang chờ cửa hàng xác nhận';
      case 'Preparing':
        return 'Cửa hàng đang chuẩn bị đơn hàng của bạn';
      case 'ReadyForPickup':
        return 'Cửa hàng đã sẵn sàng bàn giao cho shipper';
      case 'WaitingShipper':
        return 'Hệ thống đang kết nối tài xế để nhận đơn';
      case 'PickedUp':
        return 'Shipper đã nhận đơn và chuẩn bị giao';
      case 'Delivering':
        return 'Đơn hàng đang được vận chuyển đến bạn';
      case 'Delivered':
        return 'Đơn hàng đã được giao thành công';
      case 'Cancelled':
        return 'Đơn hàng đã bị hủy';
      default:
        return '';
    }
  }

  void _showCancelDialog() {
    String? selectedReason;
    final List<String> reasons = [
      'Đổi ý, không muốn mua nữa',
      'Tìm được giá tốt hơn ở nơi khác',
      'Thời gian giao hàng quá lâu',
      'Đặt nhầm sản phẩm',
      'Lý do khác',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: ReusableText(
                text: "Hủy đơn hàng",
                style: appStyle(16, kDark, FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                    text: "Vui lòng chọn lý do hủy đơn:",
                    style: appStyle(13, kGray, FontWeight.w400),
                  ),
                  SizedBox(height: 12.h),
                  ...reasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(
                        reason,
                        style: appStyle(12, kDark, FontWeight.w400),
                      ),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: kPrimary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: ReusableText(
                    text: "Đóng",
                    style: appStyle(13, kGray, FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Get.back();
                          _cancelOrder(selectedReason!);
                        },
                  child: ReusableText(
                    text: "Xác nhận hủy",
                    style: appStyle(
                      13,
                      selectedReason == null ? kGray : kRed,
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cancelOrder(String reason) async {
    setState(() {
      _isCancelling = true;
    });

    try {
      final box = GetStorage();
      final String token = box.read('token') ?? '';

      final url = Uri.parse(
        '$appBaseUrl/api/orders/${widget.order.id}/cancel',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        Get.back(result: true);
        Get.snackbar(
          'Thành công',
          'Đơn hàng đã được hủy',
          backgroundColor: kPrimary,
          colorText: kLightWhite,
          duration: const Duration(seconds: 2),
        );
      } else {
        final data = json.decode(response.body);
        Get.snackbar(
          'Lỗi',
          data['message'] ?? 'Không thể hủy đơn hàng',
          backgroundColor: kRed,
          colorText: kLightWhite,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: $e',
        backgroundColor: kRed,
        colorText: kLightWhite,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  String _mapReturnStatus(String status) {
    switch (status) {
      case 'Requested':
        return 'Bạn đã gửi yêu cầu trả hàng/hoàn tiền';
      case 'Approved':
        return 'Cửa hàng đã duyệt yêu cầu trả hàng';
      case 'Rejected':
        return 'Yêu cầu trả hàng đã bị từ chối';
      case 'Returned':
        return 'Đã xác nhận nhận lại hàng';
      case 'Refunded':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  void _showReturnDialog() {
    String? selectedReason;
    final TextEditingController reasonCtrl = TextEditingController();
    final List<String> reasons = [
      'Sản phẩm lỗi/không hoạt động',
      'Không đúng sản phẩm đặt',
      'Thiếu/rách/móp khi nhận',
      'Không còn nhu cầu',
      'Lý do khác',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: ReusableText(
                text: "Yêu cầu trả hàng/Hoàn tiền",
                style: appStyle(16, kDark, FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: "Vui lòng chọn lý do:",
                      style: appStyle(13, kGray, FontWeight.w400),
                    ),
                    SizedBox(height: 12.h),
                    ...reasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(reason,
                            style: appStyle(12, kDark, FontWeight.w400)),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: kPrimary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                            if (value != 'Lý do khác') reasonCtrl.clear();
                          });
                        },
                      );
                    }).toList(),
                    if (selectedReason == 'Lý do khác') ...[
                      SizedBox(height: 8.h),
                      TextField(
                        controller: reasonCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Nhập lý do chi tiết...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: ReusableText(
                    text: "Đóng",
                    style: appStyle(13, kGray, FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: (selectedReason == null)
                      ? null
                      : () async {
                          final reason = selectedReason == 'Lý do khác'
                              ? reasonCtrl.text.trim()
                              : selectedReason!;
                          if (reason.isEmpty) return;
                          Get.back();
                          await _requestReturn(reason);
                        },
                  child: ReusableText(
                    text: "Gửi yêu cầu",
                    style: appStyle(
                      13,
                      (selectedReason == null) ? kGray : kPrimary,
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _requestReturn(String reason) async {
    setState(() => _isRequestingReturn = true);
    try {
      final box = GetStorage();
      final accessToken = box.read('token');
      final url =
          Uri.parse('$appBaseUrl/api/orders/${widget.order.id}/return-request');
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'reason': reason}),
      );
      if (resp.statusCode == 200) {
        Get.snackbar(
          'Thành công',
          'Đã gửi yêu cầu trả hàng/hoàn tiền',
          backgroundColor: kPrimary,
          colorText: kWhite,
          icon: const Icon(Icons.check_circle, color: kWhite),
        );
        if (mounted) setState(() => _localReturnStatus = 'Requested');
      } else {
        final data = jsonDecode(resp.body);
        Get.snackbar(
          'Lỗi',
          data['message'] ?? 'Không thể gửi yêu cầu',
          backgroundColor: kRed,
          colorText: kWhite,
          icon: const Icon(Icons.error, color: kWhite),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e',
          backgroundColor: kRed, colorText: kWhite);
    } finally {
      if (mounted) setState(() => _isRequestingReturn = false);
    }
  }
}

class _TimelineStepData {
  final String title;
  final String description;
  final DateTime? timestamp;
  final bool completed;

  const _TimelineStepData({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.completed,
  });
}
