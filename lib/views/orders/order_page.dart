import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/order_controller.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/models/order_model.dart' as order_model;
import 'package:appliances_flutter/models/order_request.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/services/distance.dart';
import 'package:appliances_flutter/views/orders/widget/order_title.dart';
import 'package:appliances_flutter/views/store/widget/row_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:appliances_flutter/hooks/fetch_address.dart';
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
    final hook = useFetchDefault();
    final AddressResponse? selectedAddress = hook.data ?? address;
    final bool hasStore = store != null;
    DistanceTime data = hasStore
        ? Distance().calculateDistanceTimePrice(
            store!.coords.latitude,
            store!.coords.longitude,
            selectedAddress?.latitude ?? 0.0,
            selectedAddress?.longitude ?? 0.0,
            10,
            2,
          )
        : DistanceTime(price: 0.0, distance: 0.0, time: 0.0);

    double totalPrice = item.price + data.price;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: ReusableText(
          text: "Complete Ordering",
          style: appStyle(13, kLightWhite, FontWeight.w600),
        ),
      ),
      body: BackGroundContainer(
        color: Colors.white,
        child: SingleChildScrollView(
          // ✅ Cho phép cuộn
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderTile(appliances: appliances),
              SizedBox(height: 15.h),

              // Thông tin cửa hàng
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
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
                              ? const Icon(Icons.store, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    RowText(
                        first: "Business Hours", second: store?.time ?? "—"),
                    RowText(
                      first: "Distance from Restaurant",
                      second: "${data.distance.toStringAsFixed(2)} km",
                    ),
                    RowText(
                      first: "Price from Restaurant",
                      second: "\$ ${data.price.toStringAsFixed(2)}",
                    ),
                    RowText(
                      first: "Order Total",
                      second: "\$ ${item.price.toString()}",
                    ),
                    RowText(
                      first: "Grand Total",
                      second: "\$ ${totalPrice.toStringAsFixed(2)}",
                    ),
                    SizedBox(height: 10.h),

                    // Additives
                    ReusableText(
                      text: "Additives",
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
                  ],
                ),
              ),

              SizedBox(height: 25.h),

              // Nút Proceed
              CustomButton(
                text: "Proceed to Payment",
                btnHeight: 45,
                onTap: () {
                  // Guard: if not logged in, redirect to login first
                  final box = GetStorage();
                  final token = box.read("token");
                  if (token == null) {
                    Get.to(() => const LoginRedirect());
                    return;
                  }

                  // Guard: store or address not ready
                  if (store == null) {
                    Get.snackbar("Store not ready",
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

                  OrderRequest order = OrderRequest(
                    userId: selectedAddress!.userId,
                    orderItems: [requestItem],
                    orderTotal: item.price,
                    deliveryFee: data.price.toStringAsFixed(2),
                    grandTotal: totalPrice,
                    deliveryAddress: selectedAddress!.id,
                    storeAddress: store!.coords.address,
                    storeId: store!.id,
                    storeCoords: [
                      store!.coords.latitude,
                      store!.coords.longitude,
                    ],
                    recipientCoords: [
                      selectedAddress!.latitude ?? 0.0,
                      selectedAddress!.longitude ?? 0.0,
                    ],
                  );

                  String orderData = orderRequestToJson(order);
                  controller.createOrder(orderData);
                  print(orderData);
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
