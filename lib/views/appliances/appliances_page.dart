// ignore_for_file: unused_local_variable

import 'package:appliances_flutter/common/address_buttom_sheet.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/custom_text_field.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/appliances_controller.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';
import 'package:appliances_flutter/controllers/favorites_controller.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/hooks/fetch_store.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/cart_request.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/auth/login_page.dart';
import 'package:appliances_flutter/views/auth/phone_verification_page.dart';
import 'package:appliances_flutter/models/order_model.dart' as order_model;
import 'package:appliances_flutter/views/orders/order_page.dart';
import 'package:appliances_flutter/views/store/rating_page.dart';
import 'package:appliances_flutter/views/store/store_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppliancesPage extends StatefulHookWidget {
  const AppliancesPage({super.key, required this.appliances});

  final AppliancesModel appliances;

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage>
    with WidgetsBindingObserver {
  final TextEditingController _preferences = TextEditingController();
  final PageController _pageController = PageController();
  late AppliancesController _appliancesController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo controller và nạp additives một lần ở initState để tránh cập nhật reactive trong build
    _appliancesController = Get.put(AppliancesController());
    _appliancesController.loadAdditives(widget.appliances.additives);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refetch default address when app resumes
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final favController = Get.put(FavoritesController());
    final box = GetStorage();
    LoginResponse? user;
    // Chỉ lấy địa chỉ mặc định khi đã đăng nhập
    final String? token = box.read('token');
    final bool isLoggedIn = token != null && token.isNotEmpty;
    final defaultHook = isLoggedIn ? useFetchDefault(context) : null;
    AddressResponse? address = isLoggedIn ? defaultHook!.data : null;
    // Check xem có địa chỉ nào không (bất kể default hay không)
    final bool hasAddress = address != null;
    final hookResult = useFetchStoreById(widget.appliances.store);
    StoreModel? store = hookResult.data;
    final loginController = Get.put(LoginController());
    user = loginController.getUserInfo();

    // Show loading while fetching address (nếu có)
    if (isLoggedIn && defaultHook!.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kPrimary),
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.r)),
            child: Stack(
              children: [
                SizedBox(
                  height: 230.h,
                  child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) {
                        _appliancesController.changePage(i);
                      },
                      itemCount: widget.appliances.imageUrl.length,
                      itemBuilder: (context, i) {
                        return Container(
                          width: width,
                          height: 230.h,
                          color: kLightWhite,
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget.appliances.imageUrl[i]),
                        );
                      }),
                ),
                Positioned(
                  bottom: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            widget.appliances.imageUrl.length, (index) {
                          return Container(
                            margin: EdgeInsets.all(4.h),
                            width: 10.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _appliancesController.currentPage == index
                                        ? kSecondary
                                        : kGrayLight),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Ionicons.chevron_back_circle,
                      color: kPrimary,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () =>
                        favController.toggleFavorite(widget.appliances),
                    child: Obx(() {
                      final isFav =
                          favController.isFavorite(widget.appliances.id);
                      return CircleAvatar(
                        radius: 16.r,
                        backgroundColor: isFav ? kRed : kLightWhite,
                        child: Icon(
                          isFav ? Ionicons.heart : Ionicons.heart_outline,
                          color: isFav ? kLightWhite : kRed,
                          size: 18,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12.w,
                  child: CustomButton(
                    onTap: () {
                      Get.to(() => StorePage(
                            store: store,
                          ));
                    },
                    btnWidth: 120.w,
                    text: "Xem cửa hàng",
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReusableText(
                              text: widget.appliances.title,
                              style: appStyle(18, kDark, FontWeight.w600)),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.star, color: kSecondary, size: 16.h),
                              SizedBox(width: 4.w),
                              ReusableText(
                                text:
                                    widget.appliances.rating.toStringAsFixed(1),
                                style: appStyle(14, kDark, FontWeight.w500),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () async {
                                  final result = await Get.to(
                                    () => RatingPage(
                                      productId: widget.appliances.id,
                                      ratingType: 'Appliances',
                                    ),
                                  );
                                  if (result == true) {
                                    // Refresh trang nếu đánh giá thành công
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: kSecondary,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: ReusableText(
                                    text: "Đánh giá",
                                    style: appStyle(
                                        11, kLightWhite, FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => ReusableText(
                          text: usdToVndText((widget.appliances.price +
                                  _appliancesController.additivePrice) *
                              _appliancesController.count.value),
                          style: appStyle(18, kPrimary, FontWeight.w600)),
                    )
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  widget.appliances.description,
                  textAlign: TextAlign.justify,
                  maxLines: 8,
                  style: appStyle(11, kGray, FontWeight.w400),
                ),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  height: 18.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                        widget.appliances.appliancesTags.length, (index) {
                      final tag = widget.appliances.appliancesTags[index];
                      return Container(
                        margin: EdgeInsets.only(right: 5.w),
                        decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.r))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: ReusableText(
                            text: tag,
                            style: appStyle(11, kWhite, FontWeight.w400),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                ReusableText(
                    text: "Tuỳ chọn thêm",
                    style: appStyle(18, kDark, FontWeight.w600)),
                SizedBox(
                  height: 10.h,
                ),
                Obx(
                  () => Column(
                    children: List.generate(
                        _appliancesController.additivesList.length, (index) {
                      final additive =
                          _appliancesController.additivesList[index];
                      return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          activeColor: kSecondary,
                          value: additive.isChecked.value,
                          tristate: false,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ReusableText(
                                  text: additive.title,
                                  style: appStyle(11, kDark, FontWeight.w400)),
                              SizedBox(
                                width: 5.w,
                              ),
                              ReusableText(
                                  text: usdToVndText(
                                      double.tryParse(additive.price) ?? 0.0),
                                  style:
                                      appStyle(11, kPrimary, FontWeight.w600)),
                            ],
                          ),
                          onChanged: (bool? value) {
                            additive.toggleChecked();
                            _appliancesController.getTotalPrice();
                            _appliancesController.getCartAdditive();
                          });
                    }),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableText(
                        text: "Số lượng",
                        style: appStyle(18, kDark, FontWeight.bold)),
                    SizedBox(
                      width: 5.w,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _appliancesController.increment();
                          },
                          child: const Icon(AntDesign.pluscircleo),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Obx(
                              () => ReusableText(
                                  text: "${_appliancesController.count.value}",
                                  style: appStyle(14, kDark, FontWeight.w600)),
                            )),
                        GestureDetector(
                          onTap: () {
                            _appliancesController.decrement();
                          },
                          child: const Icon(AntDesign.minuscircleo),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                ReusableText(
                  text: "Ghi chú",
                  style: appStyle(18, kDark, FontWeight.w600),
                ),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  height: 65.h,
                  child: CustomTextField(
                    controller: _preferences,
                    hintText: "Thêm ghi chú cho món của bạn",
                    maxLines: 3,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (user == null) {
                            Get.to(() => const LoginPage());
                          } else if (user.phoneVerification == false) {
                            showVerificationSheet(context);
                          } else if (!hasAddress) {
                            showAddressSheet(context);
                          } else {
                            double price = (widget.appliances.price +
                                    _appliancesController.additivePrice) *
                                _appliancesController.count.value;

                            // Nếu store chưa tải xong, vẫn cho điều hướng.
                            // OrderPage đã xử lý khi store null và hiển thị fallback.

                            final order_model.OrderItem item =
                                order_model.OrderItem(
                                    appliancesId: order_model.AppliancesId(
                                      id: widget.appliances.id,
                                      title: widget.appliances.title,
                                      rating: widget.appliances.rating,
                                      imageUrl: widget.appliances.imageUrl,
                                      time: widget.appliances.time,
                                    ),
                                    quantity: _appliancesController.count.value,
                                    price: price,
                                    additives:
                                        _appliancesController.getCartAdditive(),
                                    instructions: _preferences.text,
                                    id: "" // placeholder id; backend assigns real id on order
                                    );

                            Get.to(
                              () => OrderPage(
                                item: item,
                                store: store,
                                appliances: widget.appliances,
                                address: address,
                              ),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 900),
                            );
                          }
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: ReusableText(
                                text: "Đặt hàng",
                                style:
                                    appStyle(18, kLightWhite, FontWeight.w600)),
                          ),
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          double price = (widget.appliances.price +
                                  _appliancesController.additivePrice) *
                              _appliancesController.count.value;

                          var data = CartRequest(
                              productId: widget.appliances.id,
                              additives:
                                  _appliancesController.getCartAdditive(),
                              quantity: _appliancesController.count.value,
                              totalPrice: price);

                          String cart = cartRequestToJson(data);

                          cartController.addToCart(cart);
                        },
                        child: CircleAvatar(
                          backgroundColor: kSecondary,
                          radius: 20.r,
                          child: const Icon(
                            Ionicons.cart,
                            color: kLightWhite,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ✅ Phiên bản mới: Không scroll, vừa khít nội dung
  Future<dynamic> showVerificationSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/restaurant_bk.png'),
              fit: BoxFit.fill,
            ),
            color: kLightWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 Fit đúng nội dung
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReusableText(
                text: "Xác thực số điện thoại",
                style: appStyle(18, kPrimary, FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              Column(
                children: List.generate(
                  verificationReasons.length,
                  (index) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading:
                          Icon(Icons.check_circle_outline, color: kPrimary),
                      title: Text(
                        verificationReasons[index],
                        textAlign: TextAlign.justify,
                        style: appStyle(12, kGray, FontWeight.normal),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              CustomButton(
                text: "Xác thực số điện thoại",
                btnHeight: 40.h,
                onTap: () {
                  Get.to(() => const PhoneVerificationPage());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
