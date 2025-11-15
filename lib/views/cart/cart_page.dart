import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/hooks/fetch_cart.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/models/cart_response.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:appliances_flutter/views/auth/verification_page.dart';
import 'package:appliances_flutter/views/cart/widget/cart_title.dart';
import 'package:appliances_flutter/views/cart/cart_checkout_page.dart';
import 'package:appliances_flutter/views/profile/shipping_address.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/utils/guest_cart.dart';
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
    final isMounted = useIsMounted();
    final hookResult = useFetchCart();
    final List<CartResponse> carts = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;
    final refetch = hookResult.refetch;

    // ... existing code ...
    // Xác định trạng thái đăng nhập sớm để dùng trong listener
    final String? token = box.read('token');
    final bool isLoggedIn = token != null &&
        token.isNotEmpty &&
        token != 'null' &&
        token != 'undefined';

    // Tự động refetch khi các key liên quan thay đổi
    useEffect(() {
      // Giỏ khách: giữ nguyên cho chế độ guest
      box.listenKey(kGuestCartKey, (_) {
        if (isMounted()) refetch?.call();
      });
      // Token: sau đăng nhập/đăng xuất
      box.listenKey('token', (_) {
        if (isMounted()) refetch?.call();
      });
      // cartCount: sau khi thêm/xoá/sửa số lượng ở chế độ đã đăng nhập
      box.listenKey('cartCount', (_) {
        if (isMounted() && isLoggedIn) refetch?.call();
      });
      // tabIndex: mở lại tab giỏ hàng
      box.listenKey('tabIndex', (val) {
        final i = int.tryParse(val?.toString() ?? '');
        if (i == 2 && isMounted()) refetch?.call();
      });
      return null;
    }, const []);

    // Lấy địa chỉ mặc định chỉ khi đã đăng nhập (đã có token/isLoggedIn ở trên)

    // Fallback: nếu hook state đang trống mà badge > 0 và chưa đăng nhập,
    // đọc trực tiếp từ storage để đảm bảo hiển thị sản phẩm ngay.
    final List<CartResponse> displayCarts = (!isLoggedIn && carts.isEmpty)
        ? readGuestCart(box)
            .map((e) => CartResponse.fromJson(e))
            .toList(growable: false)
        : carts;
    // Debug trạng thái hiển thị
    // Log một lần khi build để kiểm tra độ dài danh sách
    // Không ảnh hưởng performance đáng kể
    debugPrint(
        '[CartPage] isLoggedIn=$isLoggedIn, carts.len=${carts.length}, display.len=${displayCarts.length}');
    final defaultHook = isLoggedIn ? useFetchDefault(context) : null;
    final AddressResponse? selectedAddress =
        isLoggedIn ? defaultHook!.data : null;
    final defaultRefetch = isLoggedIn ? defaultHook!.refetch : null;

    LoginResponse? user;

    final controller = Get.put(LoginController());

    String? _token = token;
    if (_token != null) {
      user = controller.getUserInfo();
    }

    // Không chặn giỏ khi chưa đăng nhập; cho phép xem giỏ khách

    if (user != null && user.verification == false) {
      return const VerificationPage();
    }

    // Widget checkout Section: điều kiện hiển thị theo trạng thái giỏ
    final Widget checkoutSection = displayCarts.isNotEmpty
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: kLightWhite,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text:
                          "${'total'.tr} (${displayCarts.length}): ${usdToVndText(displayCarts.fold(0.0, (s, c) => s + c.totalPrice))}",
                      style: appStyle(13, kDark, FontWeight.w700),
                      maxLines: 2,
                    ),
                    if (isLoggedIn && selectedAddress == null)
                      ReusableText(
                        text: "no_shipping_address".tr,
                        style: appStyle(10, kRed, FontWeight.w400),
                      )
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: kLightWhite,
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 22.w, vertical: 12.h)),
                  onPressed: () async {
                    if (!isLoggedIn) {
                      Get.to(() => const LoginRedirect());
                      return;
                    }

                    if (selectedAddress == null) {
                      Get.to(() => ShippingAddress(onAddressSet: () {
                            defaultRefetch?.call();
                            Get.back();
                          }));
                      return;
                    }

                    // Group products by store
                    final Map<String, List<CartResponse>> storeGroups = {};
                    for (var cart in displayCarts) {
                      final storeId = cart.productId.store.id;
                      if (!storeGroups.containsKey(storeId)) {
                        storeGroups[storeId] = [];
                      }
                      storeGroups[storeId]!.add(cart);
                    }

                    debugPrint(
                        '[CartPage] Found ${storeGroups.length} store(s)');

                    // Check if all stores have valid info
                    for (var entry in storeGroups.entries) {
                      final storeId = entry.key;
                      final items = entry.value;
                      final coords = items.first.productId.store.coords;

                      if (storeId.isEmpty && coords.address.isEmpty) {
                        Get.snackbar(
                            'missing_store_info'.tr, 'missing_store_msg'.tr,
                            colorText: kLightWhite,
                            backgroundColor: kRed,
                            icon: const Icon(Icons.error_outline));
                        return;
                      }
                    }

                    // Show summary and navigate
                    final storeCount = storeGroups.length;
                    if (storeCount > 1) {
                      // Show info that multiple orders will be created
                      Get.snackbar(
                        '${'order_from_stores'.tr} $storeCount ${'stores'.tr}',
                        '${'split_order_msg'.tr} $storeCount ${'separate_orders'.tr}',
                        colorText: kLightWhite,
                        backgroundColor: kPrimary,
                        icon: const Icon(Icons.info_outline),
                        duration: const Duration(seconds: 2),
                      );
                    }

                    // Navigate to checkout page with grouped items
                    Get.to(() => CartCheckoutPage(
                          cartItems: displayCarts,
                          address: selectedAddress,
                          storeGroups: storeGroups,
                        ));
                  },
                  child: Text(
                      isLoggedIn ? 'Thanh toán' : 'Đăng nhập để thanh toán'),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      backgroundColor: kOffWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kOffWhite,
        title: ReusableText(
            text: "Giỏ hàng", style: appStyle(14, kGray, FontWeight.w600)),
      ),
      body: SafeArea(
        child: BackGroundContainer(
          color: kOffWhite,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Stack(
                    children: [
                      ListView.builder(
                          itemCount: displayCarts.length,
                          itemBuilder: (context, i) {
                            final cart = displayCarts[i];
                            return CartTile(
                                refetch: refetch,
                                color: kLightWhite,
                                cart: cart);
                          }),
                      if (isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: kLightWhite,
                            color: kPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              checkoutSection,
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}
