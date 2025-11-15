import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/common/voucher_list_sheet.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/orders_controller.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/models/order_model.dart' as order_model;
import 'package:appliances_flutter/models/order_request.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/models/voucher.dart';
import 'package:appliances_flutter/services/distance.dart';
import 'package:appliances_flutter/services/vietmap_distance.dart';
import 'package:appliances_flutter/views/orders/payment.dart';
import 'package:appliances_flutter/views/orders/widget/order_title.dart';
import 'package:appliances_flutter/views/store/widget/row_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:appliances_flutter/views/profile/shipping_address.dart';

class OrderPage extends HookWidget {
  const OrderPage({
    super.key,
    this.store,
    required this.appliances,
    required this.item,
    this.address,
  });

  final StoreModel? store;
  final AppliancesModel appliances;
  final order_model.OrderItem item;
  final AddressResponse? address;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final selectedVoucher = useState<Voucher?>(null);
    final discount = useState<double>(0.0);
    final paymentMethod = useState<String>('COD'); // Default to COD
    final distanceData = useState<DistanceTime?>(null);
    final hook = useFetchDefault(context);
    final AddressResponse? selectedAddress = hook.data ?? address;
    final bool hasStore = store != null;

    // Tính khoảng cách bằng VietMap API khi có đủ thông tin
    useEffect(() {
      if (hasStore && selectedAddress != null) {
        VietMapDistance()
            .calculateRealDistance(
          lat1: store!.coords.latitude,
          lon1: store!.coords.longitude,
          lat2: selectedAddress.latitude,
          lon2: selectedAddress.longitude,
          pricePerKm: 2,
        )
            .then((result) {
          if (result != null) {
            distanceData.value = result;
          }
        });
      }
      return null;
    }, [hasStore, selectedAddress]);

    // Fallback về Haversine nếu VietMap chưa load xong
    DistanceTime data = distanceData.value ??
        (hasStore
            ? Distance().calculateDistanceTimePrice(
                store!.coords.latitude,
                store!.coords.longitude,
                selectedAddress?.latitude ?? 0.0,
                selectedAddress?.longitude ?? 0.0,
                10,
                2,
              )
            : DistanceTime(price: 0.0, distance: 0.0, time: 0.0));

    // Phản ánh đúng tổng theo số lượng: tổng đơn = đơn giá * số lượng
    final double orderTotal = item.price * item.quantity;
    final double totalPrice = (orderTotal - discount.value) + data.price;
    double width = MediaQuery.of(context).size.width;

    return Obx(
      () => controller.paymentUrl.isNotEmpty
          ? const PaymentWebView()
          : Scaffold(
              backgroundColor: kPrimary,
              appBar: AppBar(
                backgroundColor: kPrimary,
                title: ReusableText(
                  text: "Hoàn tất đặt hàng",
                  style: appStyle(13, kLightWhite, FontWeight.w600),
                ),
              ),
              body: BackGroundContainer(
                color: Colors.white,
                child: SingleChildScrollView(
                  // ✅ Cho phép cuộn
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderTile(appliances: appliances),
                      SizedBox(height: 15.h),

                      // Thông tin cửa hàng
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.h),
                        width: width,
                        decoration: BoxDecoration(
                          color: kOffWhite,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ReusableText(
                                  text: store?.title ?? "",
                                  style: appStyle(20, kGray, FontWeight.bold),
                                ),
                                CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: kPrimary,
                                  backgroundImage: store != null
                                      ? NetworkImage(store!.logoUrl)
                                      : null,
                                  child: store == null
                                      ? const Icon(Icons.store,
                                          color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            RowText(
                                first: "Giờ mở cửa",
                                second: store?.time ?? "—"),
                            RowText(
                              first: "Khoảng cách đến cửa hàng",
                              second: "${data.distance.toStringAsFixed(2)} km",
                            ),
                            RowText(
                              first: "Thời gian ước tính",
                              second:
                                  "${(data.time * 60).toStringAsFixed(0)} phút",
                            ),
                            RowText(
                              first: "Phí từ cửa hàng",
                              second: usdToVndText(data.price),
                            ),
                            RowText(
                              first: "Tổng đơn hàng",
                              second: usdToVndText(orderTotal),
                            ),
                            if (discount.value > 0)
                              RowText(
                                first: "Giảm giá",
                                second: "- ${usdToVndText(discount.value)}",
                              ),
                            RowText(
                              first: "Tổng cộng",
                              second: usdToVndText(totalPrice),
                            ),
                            SizedBox(height: 10.h),

                            // Additives
                            ReusableText(
                              text: "Tùy chọn thêm",
                              style: appStyle(20, kGray, FontWeight.bold),
                            ),
                            SizedBox(height: 5.h),
                            Wrap(
                              // ✅ Thay vì ListView để tránh overflow ngang
                              spacing: 5.w,
                              runSpacing: 5.h,
                              children: item.additives.map((additive) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: kSecondaryLight,
                                    borderRadius: BorderRadius.circular(9.r),
                                  ),
                                  child: ReusableText(
                                    text: additive,
                                    style: appStyle(9, kGray, FontWeight.w400),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 12.h),

                            // Voucher Section
                            ReusableText(
                              text: "Voucher giảm giá",
                              style: appStyle(20, kGray, FontWeight.bold),
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
                                    storeId: store?.id,
                                    onVoucherSelected: (voucher) {
                                      selectedVoucher.value = voucher;
                                      if (voucher != null) {
                                        discount.value = voucher
                                            .calculateDiscount(orderTotal);
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedVoucher.value != null
                                                ? selectedVoucher.value!.title
                                                : 'Chọn hoặc nhập mã voucher',
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
                                              style: appStyle(12, kPrimary,
                                                  FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (selectedVoucher.value != null)
                                      Text(
                                        '-${usdToVndText(discount.value)}',
                                        style: appStyle(
                                            14, kSecondary, FontWeight.bold),
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
                              text: "Phương thức thanh toán",
                              style: appStyle(20, kGray, FontWeight.bold),
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
                                        Icon(Icons.money,
                                            color: kPrimary, size: 20.sp),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            'Thanh toán khi nhận hàng (COD)',
                                            style: appStyle(
                                                13, kDark, FontWeight.w500),
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
                                            'Thanh toán VNPay',
                                            style: appStyle(
                                                13, kDark, FontWeight.w500),
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
                          ],
                        ),
                      ),

                      SizedBox(height: 25.h),

                      // Nút Proceed
                      CustomButton(
                        text: "Tiếp tục thanh toán",
                        btnHeight: 45,
                        onTap: () async {
                          // Guard: if not logged in, redirect to login first
                          final box = GetStorage();
                          final token = box.read("token");
                          if (token == null) {
                            Get.to(() => const LoginRedirect());
                            return;
                          }

                          // Guard: store or address not ready
                          if (store == null) {
                            Get.snackbar("Cửa hàng chưa sẵn sàng",
                                "Vui lòng đợi thông tin cửa hàng tải xong",
                                colorText: kLightWhite,
                                backgroundColor: kRed,
                                icon: const Icon(Icons.error_outline));
                            return;
                          }
                          if (selectedAddress == null) {
                            // Điều hướng tới trang set địa chỉ, sau khi set sẽ refetch và quay lại
                            Get.to(() => ShippingAddress(onAddressSet: () {
                                  // Sau khi thêm địa chỉ: refetch và quay lại OrderPage
                                  hook.refetch?.call();
                                  Get.back();
                                }));
                            return;
                          }

                          final requestItem = OrderItem(
                            appliancesId: item.appliancesId.id,
                            quantity: item.quantity,
                            price: item.price,
                            additives: item.additives,
                            instructions: item.instructions,
                          );

                          // Use the selected payment method directly
                          final method = paymentMethod.value;

                          // Lưu thông tin COD để hiển thị trang tóm tắt
                          if (method == 'COD') {
                            controller.setCodInfo(
                              productTitle: appliances.title,
                              addressLine: selectedAddress.addressLine1,
                              totalPrice:
                                  (orderTotal - discount.value) + data.price,
                              quantity: item.quantity,
                            );
                          }

                          final order = OrderRequest(
                            userId: selectedAddress.userId,
                            orderItems: [requestItem],
                            orderTotal: orderTotal,
                            deliveryFee: data.price,
                            grandTotal:
                                (orderTotal - discount.value) + data.price,
                            deliveryAddress: selectedAddress.id,
                            storeAddress: store!.coords.address,
                            storeId: store!.id,
                            storeCoords: [
                              store!.coords.latitude,
                              store!.coords.longitude,
                            ],
                            recipientCoords: [
                              selectedAddress.latitude,
                              selectedAddress.longitude,
                            ],
                            paymentMethod: method,
                            promoCode: selectedVoucher.value?.code,
                            discountAmount:
                                discount.value > 0 ? discount.value : null,
                          );

                          final orderData = orderRequestToJson(order);
                          controller.createOrder(orderData, order,
                              method: method);
                          print(orderData);
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
