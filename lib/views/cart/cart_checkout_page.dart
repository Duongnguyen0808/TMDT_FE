import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/common/voucher_list_sheet.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/orders_controller.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/cart_response.dart';
import 'package:appliances_flutter/models/order_request.dart';
import 'package:appliances_flutter/models/voucher.dart';
import 'package:appliances_flutter/services/distance.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:appliances_flutter/views/orders/payment.dart';
import 'package:appliances_flutter/views/store/widget/row_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CartCheckoutPage extends HookWidget {
  final List<CartResponse> cartItems;
  final AddressResponse address;
  final Map<String, List<CartResponse>>? storeGroups;

  const CartCheckoutPage({
    super.key,
    required this.cartItems,
    required this.address,
    this.storeGroups,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final selectedVoucher = useState<Voucher?>(null);
    final discount = useState<double>(0.0);
    final paymentMethod = useState<String>('COD');

    // Group by store if not provided
    final Map<String, List<CartResponse>> groups = storeGroups ??
        {
          'default': cartItems,
        };

    // Calculate total for all items
    final orderTotal =
        cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    // Calculate total delivery fees for all stores
    double totalDeliveryFee = 0.0;
    for (var entry in groups.entries) {
      final items = entry.value;
      final coords = items.first.productId.store.coords;
      final distance = Distance().calculateDistanceTimePrice(
        lat1: coords.latitude,
        lon1: coords.longitude,
        lat2: address.latitude,
        lon2: address.longitude,
        speedKmPerHr: 30,
      );
      totalDeliveryFee += distance.price;
    }

    final grandTotal = (orderTotal - discount.value) + totalDeliveryFee;

    return Obx(
      () => controller.paymentUrl.isNotEmpty
          ? const PaymentWebView()
          : Scaffold(
              backgroundColor: kOffWhite,
              appBar: AppBar(
                backgroundColor: kOffWhite,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                title: ReusableText(
                  text: "complete_order".tr,
                  style: appStyle(13, kGray, FontWeight.w600),
                ),
              ),
              body: BackGroundContainer(
                color: kWhite,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  children: [
                    SizedBox(height: 10.h),

                    // Thông tin đơn hàng - đơn giản
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: kLightWhite,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_cart,
                                  color: kPrimary, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: ReusableText(
                                  text: groups.length > 1
                                      ? '${cartItems.length} ${"products".tr} ${"products_from_stores".tr} ${groups.length} ${"stores".tr}'
                                      : '${cartItems.length} ${"products".tr}',
                                  style: appStyle(16, kDark, FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          if (groups.length > 1) ...[
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: kPrimaryLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '${"order_will_be_split".tr} ${groups.length} ${"separate_orders".tr}',
                                style: appStyle(12, kPrimary, FontWeight.w500),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Danh sách sản phẩm
                    ReusableText(
                      text: "ordered_products".tr,
                      style: appStyle(18, kDark, FontWeight.bold),
                    ),
                    SizedBox(height: 10.h),

                    ...cartItems.map((item) {
                      final product = item.productId;
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: kLightWhite,
                          borderRadius: BorderRadius.circular(12.r),
                          border:
                              Border.all(color: kGrayLight.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            // Hình ảnh sản phẩm
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                product.imageUrl[0],
                                width: 60.w,
                                height: 60.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60.w,
                                  height: 60.w,
                                  color: kGrayLight,
                                  child: Icon(Icons.image, color: kGray),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // Thông tin sản phẩm
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: appStyle(14, kDark, FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  if (item.additives.isNotEmpty)
                                    Wrap(
                                      spacing: 5.w,
                                      children: item.additives.map((add) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: kSecondaryLight,
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            add,
                                            style: appStyle(
                                                9, kGray, FontWeight.w400),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${"quantity".tr}: ${item.quantity}',
                                        style: appStyle(
                                            12, kGray, FontWeight.w500),
                                      ),
                                      Text(
                                        usdToVndText(item.totalPrice),
                                        style: appStyle(
                                            14, kPrimary, FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 15.h),

                    // Địa chỉ giao hàng
                    ReusableText(
                      text: "delivery_address".tr,
                      style: appStyle(18, kDark, FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: kLightWhite,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: kPrimary, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  address.addressLine1,
                                  style: appStyle(14, kDark, FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Thông tin đơn hàng
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: kLightWhite,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          RowText(
                            first: "order_total_amount".tr,
                            second: usdToVndText(orderTotal),
                          ),
                          SizedBox(height: 5.h),
                          RowText(
                            first: "delivery_fee".tr,
                            second: usdToVndText(totalDeliveryFee),
                          ),
                          if (discount.value > 0) ...[
                            SizedBox(height: 5.h),
                            RowText(
                              first: "discount".tr,
                              second: "- " + usdToVndText(discount.value),
                            ),
                          ],
                          Divider(height: 20.h, color: kGray),
                          RowText(
                            first: "grand_total".tr,
                            second: usdToVndText(grandTotal),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Voucher Section
                    ReusableText(
                      text: "Voucher giảm giá",
                      style: appStyle(18, kDark, FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => VoucherListSheet(
                            orderTotal: orderTotal,
                            storeId: null, // Multi-store, no specific store
                            onVoucherSelected: (voucher) {
                              selectedVoucher.value = voucher;
                              if (voucher != null) {
                                discount.value =
                                    voucher.calculateDiscount(orderTotal);
                              } else {
                                discount.value = 0.0;
                              }
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: kGrayLight),
                          borderRadius: BorderRadius.circular(10.r),
                          color: selectedVoucher.value != null
                              ? kPrimaryLight.withOpacity(0.1)
                              : kWhite,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: selectedVoucher.value != null
                                  ? kPrimary
                                  : kGray,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedVoucher.value != null
                                        ? selectedVoucher.value!.title
                                        : 'select_voucher'.tr,
                                    style: appStyle(
                                      14,
                                      selectedVoucher.value != null
                                          ? kDark
                                          : kGray,
                                      FontWeight.w500,
                                    ),
                                  ),
                                  if (selectedVoucher.value != null)
                                    Text(
                                      selectedVoucher.value!.code,
                                      style: appStyle(
                                          12, kPrimary, FontWeight.w600),
                                    ),
                                ],
                              ),
                            ),
                            if (selectedVoucher.value != null)
                              Text(
                                '-${usdToVndText(discount.value)}',
                                style:
                                    appStyle(14, kSecondary, FontWeight.bold),
                              ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kGray,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Payment Method Section
                    ReusableText(
                      text: "payment_method".tr,
                      style: appStyle(18, kDark, FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kGrayLight),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 0),
                            title: Row(
                              children: [
                                Icon(Icons.money, color: kPrimary, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'cod_payment'.tr,
                                    style: appStyle(13, kDark, FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            value: 'COD',
                            groupValue: paymentMethod.value,
                            activeColor: kPrimary,
                            onChanged: (value) {
                              if (value != null) {
                                paymentMethod.value = value;
                              }
                            },
                          ),
                          Divider(height: 1, color: kGrayLight),
                          RadioListTile<String>(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 0),
                            title: Row(
                              children: [
                                Icon(Icons.payment,
                                    color: kSecondary, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'vnpay_payment'.tr,
                                    style: appStyle(13, kDark, FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            value: 'VNPay',
                            groupValue: paymentMethod.value,
                            activeColor: kPrimary,
                            onChanged: (value) {
                              if (value != null) {
                                paymentMethod.value = value;
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25.h),

                    // Nút Proceed
                    CustomButton(
                      text: "continue_payment".tr,
                      btnHeight: 45,
                      onTap: () async {
                        // Nếu có nhiều cửa hàng, tạo nhiều đơn hàng
                        if (storeGroups != null && storeGroups!.length > 1) {
                          // Show loading
                          Get.dialog(
                            const Center(
                                child:
                                    CircularProgressIndicator(color: kPrimary)),
                            barrierDismissible: false,
                          );

                          try {
                            int successCount = 0;
                            int failCount = 0;

                            // Get access token
                            final box = GetStorage();
                            final accessToken = box.read('token');

                            for (var entry in storeGroups!.entries) {
                              final storeId = entry.key;
                              final items = entry.value;

                              // Calculate for this store
                              final storeOrderTotal = items.fold(
                                  0.0, (sum, item) => sum + item.totalPrice);
                              final storeCoords =
                                  items.first.productId.store.coords;
                              final storeDistance =
                                  Distance().calculateDistanceTimePrice(
                                lat1: storeCoords.latitude,
                                lon1: storeCoords.longitude,
                                lat2: address.latitude,
                                lon2: address.longitude,
                                speedKmPerHr: 30,
                              );

                              // Apply discount proportionally
                              double storeDiscount = 0.0;
                              if (discount.value > 0) {
                                storeDiscount = (storeOrderTotal / orderTotal) *
                                    discount.value;
                              }

                              final storeGrandTotal = storeOrderTotal +
                                  storeDistance.price -
                                  storeDiscount;

                              // Create order items
                              final orderItems = items.map((c) {
                                final unitPrice = c.quantity > 0
                                    ? (c.totalPrice / c.quantity)
                                    : c.totalPrice;
                                return OrderItem(
                                  appliancesId: c.productId.id,
                                  quantity: c.quantity,
                                  price: unitPrice,
                                  additives: c.additives,
                                  instructions: "",
                                );
                              }).toList();

                              // Create order request
                              final order = OrderRequest(
                                userId: address.userId,
                                orderItems: orderItems,
                                orderTotal: storeOrderTotal,
                                deliveryFee: storeDistance.price,
                                grandTotal: storeGrandTotal,
                                deliveryAddress: address.id,
                                storeAddress: storeCoords.address,
                                storeId: storeId,
                                storeCoords: [
                                  storeCoords.latitude,
                                  storeCoords.longitude
                                ],
                                recipientCoords: [
                                  address.latitude,
                                  address.longitude
                                ],
                                paymentMethod: paymentMethod.value,
                                promoCode: selectedVoucher.value?.code,
                                discountAmount:
                                    storeDiscount > 0 ? storeDiscount : null,
                                deliveryDistanceKm: storeDistance.distance,
                              );

                              final orderData = orderRequestToJson(order);

                              // Try to create order
                              try {
                                final response = await http.post(
                                  Uri.parse('$appBaseUrl/api/orders'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $accessToken',
                                  },
                                  body: orderData,
                                );

                                if (response.statusCode == 201) {
                                  successCount++;
                                } else {
                                  failCount++;
                                }
                              } catch (e) {
                                failCount++;
                              }
                            }

                            // Close loading
                            Get.back();

                            // Show result
                            if (failCount == 0) {
                              Get.snackbar(
                                'Đặt hàng thành công!',
                                'Đã tạo $successCount đơn hàng',
                                colorText: kLightWhite,
                                backgroundColor: kPrimary,
                                icon: const Icon(Icons.check_circle_outline),
                              );
                              Get.offAll(() => MainScreen());
                            } else if (successCount > 0) {
                              Get.snackbar(
                                'Đặt hàng một phần',
                                'Thành công: $successCount, Thất bại: $failCount',
                                colorText: kLightWhite,
                                backgroundColor: kSecondaryLight,
                                icon: const Icon(Icons.warning_amber),
                              );
                            } else {
                              Get.snackbar(
                                'Đặt hàng thất bại',
                                'Không thể tạo đơn hàng. Vui lòng thử lại.',
                                colorText: kLightWhite,
                                backgroundColor: kRed,
                                icon: const Icon(Icons.error_outline),
                              );
                            }
                          } catch (e) {
                            Get.back();
                            Get.snackbar(
                              'Lỗi',
                              'Có lỗi xảy ra: $e',
                              colorText: kLightWhite,
                              backgroundColor: kRed,
                              icon: const Icon(Icons.error_outline),
                            );
                          }
                        } else {
                          // Single store - use first store info
                          final firstCoords =
                              cartItems.first.productId.store.coords;
                          final firstStoreId =
                              cartItems.first.productId.store.id;
                          final firstDistance =
                              Distance().calculateDistanceTimePrice(
                            lat1: firstCoords.latitude,
                            lon1: firstCoords.longitude,
                            lat2: address.latitude,
                            lon2: address.longitude,
                            speedKmPerHr: 30,
                          );

                          final items = cartItems.map((c) {
                            final unitPrice = c.quantity > 0
                                ? (c.totalPrice / c.quantity)
                                : c.totalPrice;
                            return OrderItem(
                              appliancesId: c.productId.id,
                              quantity: c.quantity,
                              price: unitPrice,
                              additives: c.additives,
                              instructions: "",
                            );
                          }).toList();

                          final order = OrderRequest(
                            userId: address.userId,
                            orderItems: items,
                            orderTotal: orderTotal,
                            deliveryFee: firstDistance.price,
                            grandTotal: grandTotal,
                            deliveryAddress: address.id,
                            storeAddress: firstCoords.address,
                            storeId: firstStoreId,
                            storeCoords: [
                              firstCoords.latitude,
                              firstCoords.longitude
                            ],
                            recipientCoords: [
                              address.latitude,
                              address.longitude
                            ],
                            paymentMethod: paymentMethod.value,
                            promoCode: selectedVoucher.value?.code,
                            discountAmount:
                                discount.value > 0 ? discount.value : null,
                            deliveryDistanceKm: firstDistance.distance,
                          );

                          if (paymentMethod.value == 'COD') {
                            controller.setCodInfo(
                              productTitle:
                                  '${cartItems.length} sản phẩm từ ${firstCoords.title.isNotEmpty ? firstCoords.title : "Cửa hàng"}',
                              addressLine: address.addressLine1,
                              totalPrice: grandTotal,
                              quantity: cartItems.fold(
                                  0, (sum, item) => sum + item.quantity),
                            );
                          }

                          final orderData = orderRequestToJson(order);
                          controller.createOrder(orderData, order,
                              method: paymentMethod.value);
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }
}
