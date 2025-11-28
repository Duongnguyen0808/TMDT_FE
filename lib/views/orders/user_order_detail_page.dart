import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/services/vietmap_service.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/utils/order_receipt_helper.dart';
import 'package:appliances_flutter/views/store/rating_page.dart';
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
  bool _isSubmittingDispute = false;
  bool _hasConfirmedReceipt = false;
  String? _localReturnStatus; // Tracks return state after user action
  String? _localDisputeStatus;
  String? _localDisputeNote;
  DateTime? _localDisputeAt;
  String? _localDisputeResolution;
  DistanceTime? _distanceTime;
  bool _isLoadingDistance = true;
  bool _isLoadingMeta = false;
  bool _isCheckingRatings = false;
  _StoreSummary? _storeSummary;
  _DriverSummary? _driverSummary;
  double? _storeUserRating;
  double? _driverUserRating;

  @override
  void initState() {
    super.initState();
    _loadDistanceAndTime();
    _localReturnStatus = widget.order.returnStatus;
    _localDisputeStatus = widget.order.customerDisputeStatus;
    _localDisputeNote = widget.order.customerDisputeNote;
    _localDisputeAt = widget.order.customerDisputeAt;
    _localDisputeResolution = widget.order.customerDisputeResolution;
    _hasConfirmedReceipt = _deriveReceiptConfirmation(widget.order);
    _fetchLogisticsMeta();
    if (widget.order.orderStatus == 'Delivered') {
      _checkExistingRatings();
    }
  }

  Future<void> _confirmReceived() async {
    if (_isConfirming || _hasConfirmedReceipt) return;

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
        final respBody = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _hasConfirmedReceipt = true;
          });
        }
        Get.snackbar(
          "Thành công",
          respBody['message'] ?? "Đã xác nhận nhận hàng và hoàn tất thanh toán",
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

  bool _deriveReceiptConfirmation(ClientOrders order) {
    final shopStatus = (order.shopDeliveryConfirmStatus ?? '').toLowerCase();
    return shopStatus == 'confirmed';
  }

  bool _shouldShowConfirmButton(ClientOrders order) {
    if (_hasConfirmedReceipt) return false;
    return canCustomerConfirmReceipt(order);
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

  bool get _hasAssignedDriver => _normalizedDriverId.isNotEmpty;

  String get _normalizedDriverId {
    final raw = widget.order.driverId.trim();
    if (raw.isEmpty) return '';
    if (raw.toLowerCase() == 'null') return '';
    return raw;
  }

  Future<void> _fetchLogisticsMeta() async {
    setState(() => _isLoadingMeta = true);
    String storeId = widget.order.storeId;
    try {
      final box = GetStorage();
      final String? token = box.read('token');
      if (token == null || token.isEmpty) {
        if (storeId.isNotEmpty) await _fetchStoreDetails(storeId);
        return;
      }

      final response = await http.get(
        Uri.parse('$appBaseUrl/api/orders/${widget.order.id}/logistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final dynamic payload = decoded is Map<String, dynamic>
            ? (decoded['data'] ?? decoded)
            : decoded;
        if (payload is Map<String, dynamic>) {
          final storeMeta = _StoreSummary.fromLogistics(payload['store']);
          final driverMeta = _DriverSummary.fromJson(payload['driver']);
          storeId = storeMeta?.id ?? storeId;
          if (mounted) {
            setState(() {
              if (storeMeta != null) _storeSummary = storeMeta;
              if (driverMeta != null) _driverSummary = driverMeta;
            });
          }
        }
      }

      if (storeId.isNotEmpty) {
        await _fetchStoreDetails(storeId);
      }
    } catch (_) {
      if (storeId.isNotEmpty) {
        await _fetchStoreDetails(storeId);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMeta = false);
      }
    }
  }

  Future<void> _fetchStoreDetails(String storeId) async {
    if (storeId.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('$appBaseUrl/api/store/byId/$storeId'),
      );
      if (response.statusCode != 200) return;
      final dynamic data = json.decode(response.body);
      if (data is! Map<String, dynamic>) return;

      final coords = data['coords'];
      String? address;
      if (coords is Map<String, dynamic>) {
        address = coords['address']?.toString();
      }

      final base = _storeSummary ??
          _StoreSummary(
            id: (data['_id'] ?? storeId).toString(),
            title: (data['title'] ?? 'Cửa hàng').toString(),
          );

      final updated = base.copyWith(
        title: data['title']?.toString(),
        logoUrl: data['logoUrl']?.toString(),
        coverUrl: data['imageUrl']?.toString(),
        address: address,
        rating: _parseNullableDouble(data['rating']),
        ratingCount: _parseNullableInt(data['ratingCount']),
      );

      if (mounted) {
        setState(() => _storeSummary = updated);
      }
    } catch (_) {
      // ignore store detail errors
    }
  }

  Future<void> _checkExistingRatings() async {
    final box = GetStorage();
    final String? token = box.read('token');
    if (token == null || token.isEmpty) return;
    setState(() => _isCheckingRatings = true);
    try {
      if (widget.order.storeId.isNotEmpty) {
        final storeRating =
            await _fetchUserRating(token, 'Store', widget.order.storeId);
        if (mounted && storeRating != null) {
          setState(() => _storeUserRating = storeRating);
        }
      }

      if (_hasAssignedDriver) {
        final driverRating =
            await _fetchUserRating(token, 'Driver', _normalizedDriverId);
        if (mounted && driverRating != null) {
          setState(() => _driverUserRating = driverRating);
        }
      }
    } catch (_) {
      // ignore rating fetch errors
    } finally {
      if (mounted) {
        setState(() => _isCheckingRatings = false);
      }
    }
  }

  Future<double?> _fetchUserRating(
      String token, String ratingType, String targetId) async {
    if (targetId.isEmpty) return null;
    try {
      final uri = Uri.parse('$appBaseUrl/api/rating').replace(
        queryParameters: {
          'ratingType': ratingType,
          'product': targetId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['status'] == true) {
          final rating = decoded['rating'];
          if (rating is num) {
            return rating.toDouble();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> _openRatingPage(String ratingType, String targetId) async {
    if (targetId.isEmpty) return;
    final result = await Get.to(() => RatingPage(
          productId: targetId,
          ratingType: ratingType,
        ));
    if (result == true && mounted) {
      await _checkExistingRatings();
    }
  }

  double? _parseNullableDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  int? _parseNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool isCancelled = order.orderStatus == 'Cancelled';
    final bool canCancel =
        _orderCancellableStatuses.contains(order.orderStatus);
    final Widget? deliveryProofSection = _buildDeliveryProofSection(order);
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 12.h,
            bottom: bottomInset + 24.h,
          ),
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

              if (deliveryProofSection != null) ...[
                deliveryProofSection,
                SizedBox(height: 16.h),
              ],

              if (order.orderStatus == 'Delivered') ...[
                _buildExperienceCard(order),
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

              // Confirm Received Button (available for any delivered order once shop completed hand-off)
              if (_shouldShowConfirmButton(order))
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

  Widget _buildExperienceCard(ClientOrders order) {
    final children = <Widget>[
      _buildStoreRatingTile(),
    ];

    if (_hasAssignedDriver) {
      children.addAll([
        SizedBox(height: 12.h),
        Divider(height: 1, color: kGrayLight),
        SizedBox(height: 12.h),
        _buildDriverRatingTile(),
      ]);
    }

    if (_isCheckingRatings) {
      children.addAll([
        SizedBox(height: 12.h),
        _buildMetaLoadingRow('Đang kiểm tra lịch sử đánh giá của bạn...'),
      ]);
    }

    return _buildInfoCard(title: "Đánh giá trải nghiệm", children: children);
  }

  Widget _buildStoreRatingTile() {
    if (_isLoadingMeta && _storeSummary == null) {
      return _buildMetaLoadingRow('Đang tải thông tin cửa hàng...');
    }

    final summary = _storeSummary;
    String title = 'Cửa hàng của bạn';
    if (summary != null && summary.title.isNotEmpty) {
      title = summary.title;
    }
    final String? address = summary?.address;
    final double? avgRating = summary?.rating;
    final int ratingCount = summary?.ratingCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(
                summary?.logoUrl ?? summary?.coverUrl, Icons.storefront),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                    text: title,
                    style: appStyle(14, kDark, FontWeight.w600),
                  ),
                  if (address?.isNotEmpty == true) ...[
                    SizedBox(height: 4.h),
                    ReusableText(
                      text: address!,
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ] else ...[
                    SizedBox(height: 4.h),
                    ReusableText(
                      text: 'Thông tin cửa hàng đang được cập nhật',
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                  if (avgRating != null) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4.w),
                        ReusableText(
                          text:
                              '${avgRating.toStringAsFixed(1)} (${ratingCount.toString()} đánh giá)',
                          style: appStyle(12, kDark, FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                  if (_storeUserRating != null) ...[
                    SizedBox(height: 6.h),
                    _buildUserRatingChip(_storeUserRating!, color: kPrimary),
                  ] else ...[
                    SizedBox(height: 6.h),
                    ReusableText(
                      text: 'Bạn chưa đánh giá cửa hàng này.',
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        CustomButton(
          onTap: () => _openRatingPage('Store', widget.order.storeId),
          btnHeight: 42.h,
          btnColor: kPrimary,
          text: _storeUserRating != null
              ? 'Cập nhật đánh giá cửa hàng'
              : 'Đánh giá ngay',
        ),
      ],
    );
  }

  Widget _buildDriverRatingTile() {
    if (_isLoadingMeta && _driverSummary == null) {
      return _buildMetaLoadingRow('Đang tải thông tin tài xế...');
    }

    final summary = _driverSummary;
    String title = 'Tài xế của bạn';
    if (summary != null && summary.name.isNotEmpty) {
      title = summary.name;
    }
    final String? phone = summary?.phone;
    final String? plate = summary?.vehiclePlate;
    final String? status = summary?.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(summary?.avatar, Icons.delivery_dining),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                    text: title,
                    style: appStyle(14, kDark, FontWeight.w600),
                  ),
                  if (plate?.isNotEmpty == true) ...[
                    SizedBox(height: 4.h),
                    ReusableText(
                      text: 'Biển số: $plate',
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                  if (status?.isNotEmpty == true) ...[
                    SizedBox(height: 4.h),
                    ReusableText(
                      text: 'Trạng thái: $status',
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                  if (phone?.isNotEmpty == true) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: kGray),
                        SizedBox(width: 6.w),
                        ReusableText(
                          text: phone!,
                          style: appStyle(12, kDark, FontWeight.w500),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(height: 4.h),
                    ReusableText(
                      text: 'Thông tin liên hệ sẽ hiển thị khi có sẵn',
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                  if (_driverUserRating != null) ...[
                    SizedBox(height: 6.h),
                    _buildUserRatingChip(_driverUserRating!, color: kSecondary),
                  ] else ...[
                    SizedBox(height: 6.h),
                    ReusableText(
                      text: 'Bạn chưa đánh giá tài xế này.',
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        CustomButton(
          onTap: () => _openRatingPage('Driver', _normalizedDriverId),
          btnHeight: 42.h,
          btnColor: kSecondary,
          text: _driverUserRating != null
              ? 'Cập nhật đánh giá tài xế'
              : 'Đánh giá ngay',
        ),
      ],
    );
  }

  Widget _buildMetaLoadingRow(String message) {
    return Row(
      children: [
        SizedBox(
          width: 18.w,
          height: 18.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ReusableText(
            text: message,
            style: appStyle(12, kGray, FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? imageUrl, IconData fallback) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final displayUrl = imageUrl ?? '';
    return ClipOval(
      child: Container(
        width: 48.w,
        height: 48.w,
        color: kGrayLight,
        child: hasImage
            ? Image.network(
                displayUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallback,
                  color: kGray,
                  size: 22.sp,
                ),
              )
            : Icon(
                fallback,
                color: kGray,
                size: 22.sp,
              ),
      ),
    );
  }

  Widget _buildUserRatingChip(double rating, {Color color = kPrimary}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          ReusableText(
            text: 'Bạn đã đánh giá ${rating.toStringAsFixed(1)}★',
            style: appStyle(11, color, FontWeight.w600),
          ),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ReusableText(
              text: title,
              style: titleStyle ?? appStyle(13, kGray, FontWeight.w400),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: ReusableText(
              text: value,
              style: valueStyle ??
                  appStyle(13, valueColor ?? kDark, FontWeight.w600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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

  Widget? _buildDeliveryProofSection(ClientOrders order) {
    final proofPhoto = order.deliveryProofPhoto ?? '';
    final bool hasProof = proofPhoto.isNotEmpty;
    final String shopStatus = (order.shopDeliveryConfirmStatus ?? 'None');
    final String disputeStatus = (_localDisputeStatus?.isNotEmpty == true)
        ? _localDisputeStatus!
        : (order.customerDisputeStatus ?? 'None');
    final bool hasDisputeInfo = disputeStatus != 'None' ||
        (_localDisputeNote ?? order.customerDisputeNote ?? '').isNotEmpty;

    if (!hasProof && shopStatus == 'None' && !hasDisputeInfo) {
      return null;
    }

    final List<Widget> children = [
      Row(
        children: [
          _buildStatusChip(
            icon: Icons.verified_outlined,
            label: _mapShopConfirmStatus(shopStatus),
            color: _shopConfirmColor(shopStatus),
          ),
          SizedBox(width: 8.w),
          _buildStatusChip(
            icon: Icons.report_problem_outlined,
            label: _mapDisputeStatus(disputeStatus),
            color: _disputeStatusColor(disputeStatus),
          ),
        ],
      ),
    ];

    final issueStatus = order.deliveryIssueStatus ?? 'None';
    if (issueStatus.isNotEmpty && issueStatus != 'None') {
      children.add(SizedBox(height: 8.h));
      children.add(
        ReusableText(
          text: 'Theo dõi: ${_mapDeliveryIssue(issueStatus)}',
          style: appStyle(12, kGray, FontWeight.w400),
        ),
      );
    }

    if (hasProof) {
      children.add(SizedBox(height: 12.h));
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              proofPhoto,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: kGrayLight,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image, size: 32.sp, color: kGray),
              ),
            ),
          ),
        ),
      );
      if (order.deliveryProofNote?.isNotEmpty == true) {
        children.add(SizedBox(height: 6.h));
        children.add(
          ReusableText(
            text: 'Ghi chú tài xế: ${order.deliveryProofNote}',
            style: appStyle(12, kGray, FontWeight.w400),
          ),
        );
      }
      if (order.deliveryProofRecipient?.isNotEmpty == true) {
        children.add(SizedBox(height: 4.h));
        children.add(
          ReusableText(
            text: 'Người nhận: ${order.deliveryProofRecipient}',
            style: appStyle(12, kDark, FontWeight.w500),
          ),
        );
      }
      if (order.deliveryProofAt != null) {
        children.add(SizedBox(height: 4.h));
        children.add(
          ReusableText(
            text:
                'Gửi lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(order.deliveryProofAt!)}',
            style: appStyle(12, kGray, FontWeight.w400),
          ),
        );
      }
      if (order.deliveryProofLocation != null) {
        children.add(SizedBox(height: 4.h));
        children.add(
          ReusableText(
            text:
                'Vị trí: ${_formatDeliveryProofLocation(order.deliveryProofLocation!)}',
            style: appStyle(12, kGray, FontWeight.w400),
          ),
        );
      }
    }

    final disputeNote = (_localDisputeNote?.isNotEmpty == true)
        ? _localDisputeNote!
        : (order.customerDisputeNote ?? '');
    final disputeResolution = (_localDisputeResolution?.isNotEmpty == true)
        ? _localDisputeResolution!
        : (order.customerDisputeResolution ?? '');
    final disputeAt = _localDisputeAt ?? order.customerDisputeAt;
    final bool disputePending = disputeStatus == 'Pending';

    if (shopStatus == 'Pending') {
      children.add(SizedBox(height: 12.h));
      children.add(
        ReusableText(
          text: 'Tài xế đã gửi ảnh bàn giao. Cửa hàng sẽ xác nhận sớm.',
          style: appStyle(12, kGray, FontWeight.w400),
        ),
      );
    } else if (shopStatus == 'Rejected' &&
        (order.shopDeliveryRejectReason?.isNotEmpty ?? false)) {
      children.add(SizedBox(height: 12.h));
      children.add(
        ReusableText(
          text: 'Cửa hàng phản hồi: ${order.shopDeliveryRejectReason}',
          style: appStyle(12, kRed, FontWeight.w500),
        ),
      );
    }

    if (disputeNote.isNotEmpty) {
      children.add(SizedBox(height: 12.h));
      children.add(
        ReusableText(
          text: 'Khiếu nại: $disputeNote',
          style: appStyle(12, kDark, FontWeight.w500),
        ),
      );
    }
    if (disputeAt != null) {
      children.add(SizedBox(height: 4.h));
      children.add(
        ReusableText(
          text:
              'Thời gian gửi: ${DateFormat('dd/MM/yyyy HH:mm').format(disputeAt)}',
          style: appStyle(11, kGray, FontWeight.w400),
        ),
      );
    }
    if (disputePending) {
      children.add(SizedBox(height: 8.h));
      children.add(
        ReusableText(
          text: 'Cửa hàng đang xác minh khiếu nại của bạn.',
          style: appStyle(12, Colors.orange.shade700, FontWeight.w500),
        ),
      );
    }
    if (!disputePending && disputeResolution.isNotEmpty) {
      children.add(SizedBox(height: 8.h));
      children.add(
        ReusableText(
          text: 'Kết quả: $disputeResolution',
          style: appStyle(12, kGray, FontWeight.w500),
        ),
      );
    }

    final bool canDispute = _canRaiseDispute(order);
    if (canDispute) {
      children.add(SizedBox(height: 12.h));
      children.add(
        CustomButton(
          onTap: _isSubmittingDispute ? () {} : () => _showDisputeDialog(),
          btnColor: kSecondary,
          btnHeight: 45.h,
          text: _isSubmittingDispute
              ? 'Đang gửi khiếu nại...'
              : 'Tôi chưa nhận được hàng',
        ),
      );
    }

    return _buildInfoCard(
      title: 'Xác minh giao hàng',
      children: children,
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: appStyle(12, color, FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _mapShopConfirmStatus(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ cửa hàng xác nhận';
      case 'Confirmed':
        return 'Cửa hàng đã xác nhận';
      case 'Rejected':
        return 'Cửa hàng yêu cầu bổ sung';
      default:
        return 'Chưa xác minh';
    }
  }

  Color _shopConfirmColor(String status) {
    switch (status) {
      case 'Confirmed':
        return kPrimary;
      case 'Rejected':
        return kRed;
      case 'Pending':
        return Colors.orange;
      default:
        return kGray;
    }
  }

  String _mapDisputeStatus(String status) {
    switch (status) {
      case 'Pending':
        return 'Đang xử lý';
      case 'Resolved':
        return 'Đã xử lý';
      case 'Rejected':
        return 'Bị từ chối';
      default:
        return 'Chưa khiếu nại';
    }
  }

  Color _disputeStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return kRed;
      default:
        return kGray;
    }
  }

  String _mapDeliveryIssue(String status) {
    switch (status) {
      case 'Warned':
        return 'Hệ thống đang nhắc tài xế cập nhật bằng chứng.';
      case 'Escalated':
        return 'Đơn đang được kiểm tra thêm.';
      case 'Disputed':
        return 'Khách hoặc cửa hàng đang khiếu nại.';
      case 'Resolved':
        return 'Vấn đề đã xử lý.';
      default:
        return 'Không có cảnh báo.';
    }
  }

  String _formatDeliveryProofLocation(DeliveryProofLocation location) {
    return '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
  }

  bool _canRaiseDispute(ClientOrders order) {
    if (_hasConfirmedReceipt) return false;
    final String status =
        (_localDisputeStatus ?? order.customerDisputeStatus ?? 'None');
    if ((order.deliveryProofPhoto ?? '').isEmpty) return false;
    if (order.orderStatus == 'Cancelled') return false;
    final bool orderStage =
        order.orderStatus == 'Delivering' || order.orderStatus == 'Delivered';
    if (!orderStage) return false;
    if (_isSubmittingDispute) return false;
    return status == 'None' || status == 'Rejected';
  }

  void _showDisputeDialog() {
    final List<String> reasons = [
      'Không nhận được hàng',
      'Nhận thiếu hàng',
      'Hàng giao sai người',
      'Ảnh bàn giao không đúng',
      'Lý do khác',
    ];
    String? selectedReason;
    final TextEditingController detailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: ReusableText(
                text: 'Báo chưa nhận hàng',
                style: appStyle(16, kDark, FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: 'Vui lòng chọn lý do:',
                      style: appStyle(13, kGray, FontWeight.w400),
                    ),
                    SizedBox(height: 12.h),
                    ...reasons.map(
                      (reason) => RadioListTile<String>(
                        title: Text(
                          reason,
                          style: appStyle(12, kDark, FontWeight.w400),
                        ),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: kPrimary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedReason = value;
                            if (value != 'Lý do khác') {
                              detailCtrl.clear();
                            }
                          });
                        },
                      ),
                    ),
                    if (selectedReason == 'Lý do khác') ...[
                      SizedBox(height: 8.h),
                      TextField(
                        controller: detailCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Mô tả chi tiết vấn đề...',
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
                    text: 'Đóng',
                    style: appStyle(13, kGray, FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          final detail = detailCtrl.text.trim();
                          if (selectedReason == 'Lý do khác' &&
                              detail.isEmpty) {
                            Get.snackbar(
                              'Thiếu thông tin',
                              'Vui lòng mô tả lý do khi chọn mục này',
                              backgroundColor: kRed,
                              colorText: kWhite,
                            );
                            return;
                          }
                          Get.back();
                          _submitDispute(
                            selectedReason!,
                            detail,
                          );
                        },
                  child: ReusableText(
                    text: 'Gửi khiếu nại',
                    style: appStyle(
                      13,
                      selectedReason == null ? kGray : kPrimary,
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

  Future<void> _submitDispute(String reason, String detail) async {
    setState(() => _isSubmittingDispute = true);
    try {
      final box = GetStorage();
      final accessToken = box.read('token');
      final url = Uri.parse(
          '$appBaseUrl/api/orders/${widget.order.id}/delivery-dispute');
      final payload = {
        'reason': reason,
        if (detail.isNotEmpty) 'note': detail,
      };
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200) {
        final composed =
            detail.isNotEmpty ? '$reason - $detail' : reason.trim();
        Get.snackbar(
          'Đã gửi',
          'Chúng tôi sẽ làm việc với cửa hàng và tài xế ngay.',
          backgroundColor: kPrimary,
          colorText: kWhite,
          icon: const Icon(Icons.check_circle, color: kWhite),
        );
        if (mounted) {
          setState(() {
            _localDisputeStatus = 'Pending';
            _localDisputeNote = composed;
            _localDisputeAt = DateTime.now();
            _localDisputeResolution = null;
          });
        }
      } else {
        final data = jsonDecode(resp.body);
        Get.snackbar(
          'Lỗi',
          data['message'] ?? 'Không thể gửi khiếu nại',
          backgroundColor: kRed,
          colorText: kWhite,
          icon: const Icon(Icons.error, color: kWhite),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi: $e',
        backgroundColor: kRed,
        colorText: kWhite,
        icon: const Icon(Icons.error, color: kWhite),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingDispute = false);
    }
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
        title: 'Đã gán tài xế',
        description: order.shipperPickupBy != null
            ? 'Tài xế nhận trước ${order.shipperPickupBy}'
            : 'Hệ thống đang tìm tài xế gần nhất',
        timestamp: order.pickupAssignedAt,
        completed: shipperAssigned,
      ),
      _TimelineStepData(
        title: 'Tài xế nhận hàng',
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
        return 'Đang gán tài xế';
      case 'PickedUp':
        return 'Tài xế đã nhận';
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
        return 'Cửa hàng đã sẵn sàng bàn giao cho tài xế';
      case 'WaitingShipper':
        return 'Hệ thống đang kết nối tài xế để nhận đơn';
      case 'PickedUp':
        return 'Tài xế đã nhận đơn và chuẩn bị giao';
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

class _StoreSummary {
  final String id;
  final String title;
  final String? logoUrl;
  final String? coverUrl;
  final String? address;
  final double? rating;
  final int? ratingCount;

  const _StoreSummary({
    required this.id,
    required this.title,
    this.logoUrl,
    this.coverUrl,
    this.address,
    this.rating,
    this.ratingCount,
  });

  _StoreSummary copyWith({
    String? id,
    String? title,
    String? logoUrl,
    String? coverUrl,
    String? address,
    double? rating,
    int? ratingCount,
  }) {
    return _StoreSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  static _StoreSummary? fromLogistics(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final String id = (data['id'] ?? data['_id'] ?? '').toString();
    if (id.isEmpty) return null;
    return _StoreSummary(
      id: id,
      title: (data['title'] ?? data['name'] ?? 'Cửa hàng').toString(),
      logoUrl: data['logoUrl']?.toString(),
      coverUrl: data['imageUrl']?.toString(),
      address: data['address']?.toString(),
      rating: data['rating'] is num ? (data['rating'] as num).toDouble() : null,
      ratingCount: data['ratingCount'] is num
          ? (data['ratingCount'] as num).toInt()
          : null,
    );
  }
}

class _DriverSummary {
  final String id;
  final String name;
  final String? phone;
  final String? avatar;
  final String? status;
  final String? vehiclePlate;
  final String? vehicleType;

  const _DriverSummary({
    required this.id,
    required this.name,
    this.phone,
    this.avatar,
    this.status,
    this.vehiclePlate,
    this.vehicleType,
  });

  static _DriverSummary? fromJson(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final String id =
        (data['id'] ?? data['_id'] ?? data['userId'] ?? '').toString();
    if (id.isEmpty) return null;
    return _DriverSummary(
      id: id,
      name: (data['name'] ?? data['username'] ?? 'Shipper').toString(),
      phone: data['phone']?.toString(),
      avatar: data['avatar']?.toString(),
      status: data['status']?.toString(),
      vehiclePlate: data['vehiclePlate']?.toString(),
      vehicleType: data['vehicleType']?.toString(),
    );
  }
}
