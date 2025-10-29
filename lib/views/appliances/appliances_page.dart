// ignore_for_file: prefer_const_constructors, unnecessary_import, unused_local_variable, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks, non_constant_identifier_names

import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/custom_text_field.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/appliances_controller.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/hooks/fetch_stores.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/auth/login_page.dart';
import 'package:appliances_flutter/views/auth/phone_verification_page.dart';
import 'package:appliances_flutter/views/store/store_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

class AppliancesPage extends StatefulHookWidget {
  const AppliancesPage({super.key, required this.appliances});

  final AppliancesModel appliances;

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  final TextEditingController _preferences = TextEditingController();
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    LoginResponse? user;
    final hookResult = useFetchStores(widget.appliances.store);
    final controller = Get.put(AppliancesController());
    final loginController = Get.put(LoginController());

    user = loginController.getUserInfo();
    controller.loadAdditives(widget.appliances.additives);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30.r),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 230.h,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) {
                      controller.changePage(i);
                    },
                    itemCount: widget.appliances.imageUrl.length,
                    itemBuilder: (context, i) {
                      return Container(
                        width: width,
                        height: 230.h,
                        color: kLightWhite,
                        child: CachedNetworkImage(
                          imageUrl: widget.appliances.imageUrl[i],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.appliances.imageUrl.length,
                          (index) {
                            return Container(
                              margin: EdgeInsets.all(4.h),
                              height: 10.h,
                              width: 10.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.currentPage == index
                                    ? kSecondary
                                    : kGrayLight,
                              ),
                            );
                          },
                        ),
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
                    child: Icon(Icons.arrow_back_ios_new,
                        color: kPrimary, size: 30),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12.w,
                  child: CustomButton(
                    onTap: () {
                      Get.to(() => StorePage(
                            store: hookResult.data,
                          ));
                    },
                    btnWidth: 120.w,
                    text: "Mở cửa hàng",
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
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableText(
                      text: widget.appliances.title,
                      style: appStyle(18, kDark, FontWeight.w600),
                    ),
                    Obx(
                      () => ReusableText(
                        text:
                            "\$ ${((widget.appliances.price + controller.additivePrice) * controller.count.value)} ",
                        style: appStyle(18, kDark, FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  widget.appliances.description,
                  maxLines: 8,
                  style: appStyle(14, kGray, FontWeight.w400),
                ),
                SizedBox(
                  height: 18.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      widget.appliances.appliancesTags.length,
                      (index) {
                        final tag = widget.appliances.appliancesTags[index];
                        return Container(
                          margin: EdgeInsets.only(right: 6.w),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: ReusableText(
                              text: tag,
                              style: appStyle(11, kWhite, FontWeight.w400),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                ReusableText(
                  text: "Thông tin cửa hàng",
                  style: appStyle(18, kDark, FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                Obx(
                  () => Column(
                    children:
                        List.generate(controller.additivesList.length, (index) {
                      final additive = controller.additivesList[index];
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        tristate: false,
                        activeColor: kSecondary,
                        value: additive.isChecked.value,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ReusableText(
                              text: additive.title,
                              style: appStyle(12, kDark, FontWeight.w400),
                            ),
                            SizedBox(width: 5.w),
                            ReusableText(
                              text: "\$ ${additive.price}",
                              style: appStyle(12, kPrimary, FontWeight.w600),
                            ),
                          ],
                        ),
                        onChanged: (bool? value) {
                          additive.toggleChecked();
                          controller.getTotalPrice();
                        },
                      );
                    }),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableText(
                      text: "Số lượng",
                      style: appStyle(12, kDark, FontWeight.bold),
                    ),
                    SizedBox(width: 5.w),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.increment();
                          },
                          child: Icon(AntDesign.pluscircleo),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Obx(
                            () => ReusableText(
                              text: "${controller.count.value}",
                              style: appStyle(14, kDark, FontWeight.w600),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.decrement();
                          },
                          child: Icon(AntDesign.minuscircleo),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                ReusableText(
                  text: "Ghi chú",
                  style: appStyle(18, kDark, FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  height: 65.h,
                  child: CustomTextField(
                    controller: _preferences,
                    hintText: "Thêm ghi chú cho đơn hàng",
                    maxLines: 3,
                  ),
                ),
                SizedBox(height: 15.h),
                GestureDetector(
                  onTap: () {
                    if (user == null) {
                      Get.to(() => const LoginPage());
                    } else if (user.phoneVerification == false) {
                      showVerificationSheet(context);
                    } else {
                      print("Thêm vào giỏ hàng");
                    }
                  },
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: ReusableText(
                            text: "Thêm vào giỏ hàng",
                            style: appStyle(16, kWhite, FontWeight.w600),
                          ),
                        ),
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: kSecondary,
                          child: Icon(Ionicons.cart, color: kLightWhite),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
