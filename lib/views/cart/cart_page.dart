import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/custom_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/controllers/orders_controller.dart';
import 'package:appliances_flutter/hooks/fetch_cart.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/models/cart_response.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:appliances_flutter/views/auth/verification_page.dart';
import 'package:appliances_flutter/views/cart/widget/cart_title.dart';
import 'package:appliances_flutter/views/orders/payment.dart';
import 'package:appliances_flutter/services/distance.dart';
import 'package:appliances_flutter/views/profile/shipping_address.dart';
import 'package:appliances_flutter/models/order_request.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartPage extends HookWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final hookResult = useFetchCart();
    final List<CartResponse> carts = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;
    final refetch = hookResult.refetch;

    // Lấy địa chỉ mặc định để tính phí giao hàng
    final defaultHook = useFetchDefault(context);
    final AddressResponse? selectedAddress = defaultHook.data;
    final defaultRefetch = defaultHook.refetch;

    LoginResponse? user;

    final controller = Get.put(LoginController());
    final orderController = Get.put(OrdersController());

    String? token = box.read('token');

    if (token != null) {
      user = controller.getUserInfo();
    }

    if (token == null) {
      return const LoginRedirect();
    }

    if (user != null && user.verification == false) {
      return const VerificationPage();
    }

    return Obx(() => orderController.paymentUrl.isNotEmpty
        ? const PaymentWebView()
        : Scaffold(
            backgroundColor: kPrimary,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: kOffWhite,
              title: ReusableText(
                  text: "Giỏ hàng", style: appStyle(14, kGray, FontWeight.w600)),
            ),
            body: SafeArea(
              child: CustomContainer(
                  containerContent: isLoading
                      ? const FoodsListShimmer()
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: ListView.builder(
                                itemCount: carts.length,
                                itemBuilder: (context, i) {
                                  var cart = carts[i];
                                  return CartTile(
                                      refetch: refetch,
                                      color: kLightWhite,
                                      cart: cart);
                                }),
                          ),
                        )),
            ),
            bottomNavigationBar: carts.isEmpty
                ? null
                : Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: const BoxDecoration(color: kLightWhite),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReusableText(
                              text:
                                  "Tổng (${carts.length}): ${usdToVndText(carts.fold(0.0, (s, c) => s + c.totalPrice))}",
                              style: appStyle(12, kDark, FontWeight.w600),
                            ),
                            if (selectedAddress == null)
                              ReusableText(
                                text: "Chưa có địa chỉ giao hàng",
                                style: appStyle(10, kRed, FontWeight.w400),
                              )
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: kLightWhite,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 10.h)),
                          onPressed: () async {
                            // Yêu cầu địa chỉ nếu chưa có
                            if (selectedAddress == null) {
                              Get.to(() => ShippingAddress(onAddressSet: () {
                                    defaultRefetch?.call();
                                    Get.back();
                                  }));
                              return;
                            }

                            // Kiểm tra cùng cửa hàng
                            final firstStoreId = carts.first.productId.store.id;
                            final multiStore = carts.any(
                                (c) => c.productId.store.id != firstStoreId);
                            if (multiStore) {
                              Get.snackbar('Giỏ hàng chứa nhiều cửa hàng',
                                  'Vui lòng chỉ giữ sản phẩm từ một cửa hàng để thanh toán.',
                                  colorText: kLightWhite,
                                  backgroundColor: kRed,
                                  icon: const Icon(Icons.error_outline));
                              return;
                            }

                            // Chọn phương thức
                            final method = await showModalBottomSheet<String>(
                              context: context,
                              builder: (ctx) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.payment),
                                        title: const Text('Thanh toán VNPay'),
                                        onTap: () => Navigator.pop(ctx, 'VNPay'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.money),
                                        title: const Text('Thanh toán COD'),
                                        onTap: () => Navigator.pop(ctx, 'COD'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (method == null) return;

                            // Tính phí giao hàng từ cửa hàng tới địa chỉ
                            final coords = carts.first.productId.store.coords;
                            final distance = Distance().calculateDistanceTimePrice(
                                coords.latitude,
                                coords.longitude,
                                selectedAddress.latitude ?? 0.0,
                                selectedAddress.longitude ?? 0.0,
                                10,
                                2);

                            final orderTotal =
                                carts.fold(0.0, (s, c) => s + c.totalPrice);
                            final grandTotal = orderTotal + distance.price;

                            // Map cart -> OrderItems (sử dụng price mỗi đơn vị)
                            final items = carts.map((c) {
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
                              userId: selectedAddress.userId,
                              orderItems: items,
                              orderTotal: orderTotal,
                              deliveryFee: distance.price.toStringAsFixed(2),
                              grandTotal: grandTotal,
                              deliveryAddress: selectedAddress.id,
                              storeAddress: coords.address,
                              storeId: firstStoreId,
                              storeCoords: [coords.latitude, coords.longitude],
                              recipientCoords: [
                                selectedAddress.latitude ?? 0.0,
                                selectedAddress.longitude ?? 0.0,
                              ],
                              paymentMethod: method,
                            );

                            final orderData = orderRequestToJson(order);
                            orderController.createOrder(orderData, order,
                                method: method);
                          },
                          child: const Text('Thanh toán'),
                        ),
                      ],
                    ),
                  ),
          ));
  }
}
