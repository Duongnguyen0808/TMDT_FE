// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison, unused_local_variable

import 'package:appliances_flutter/views/profile/my_reviews_page.dart';
import 'package:appliances_flutter/views/profile/edit_profile_page.dart';
import 'package:appliances_flutter/common/profile_app_bar.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:appliances_flutter/views/auth/verification_page.dart';
import 'package:appliances_flutter/views/orders/user_orders.dart' as orders;
import 'package:appliances_flutter/views/profile/addresses_page.dart';
import 'package:appliances_flutter/views/profile/service_center_page.dart';
import 'package:appliances_flutter/views/profile/support_page.dart';
import 'package:appliances_flutter/views/profile/favorites_page.dart';
import 'package:appliances_flutter/views/profile/settings_page.dart';
import 'package:appliances_flutter/views/chat/chat_list_page.dart';
import 'package:appliances_flutter/views/voucher/voucher_page.dart';

import 'package:appliances_flutter/views/profile/widget/profile_title_widget.dart';
import 'package:appliances_flutter/views/profile/widget/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/custom_container.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    LoginResponse? user;
    final controller = Get.put(LoginController());

    final box = GetStorage();

    String? token = box.read('token');

    if (token != null) {
      user = controller.getUserInfo();
    }

    if (token == null) {
      return LoginRedirect();
    }

    if (user != null && user.verification == false) {
      return VerificationPage();
    }

    return Scaffold(
        backgroundColor: kPrimary,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: ProfileAppBar(),
        ),
        body: SafeArea(
          child: CustomContainer(
              containerContent: Column(children: [
            UserInfoWidget(user: user),
            SizedBox(height: 10.h),
            Container(
              height: 210.h,
              decoration: const BoxDecoration(color: kLightWhite),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ProfileTileWidget(
                      onTap: () {
                        Get.to(() => const orders.UserOrders(),
                            transition: Transition.cupertino,
                            duration: const Duration(milliseconds: 900));
                      },
                      title: 'my_orders'.tr,
                      icon: Icons.shopping_cart),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const FavoritesPage(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 900));
                    },
                    title: 'favorites'.tr,
                    icon: Ionicons.heart_outline,
                  ),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const EditProfilePage(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 600));
                    },
                    title: 'Chỉnh sửa hồ sơ',
                    icon: Ionicons.create_outline,
                  ),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const MyReviewsPage(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 600));
                    },
                    title: 'my_reviews'.tr,
                    icon: Ionicons.chatbubbles_outline,
                  ),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const VoucherPage());
                    },
                    title: 'vouchers'.tr,
                    icon: MaterialCommunityIcons.tag_outline,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            Container(
              height: 210.h,
              decoration: const BoxDecoration(color: kLightWhite),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ProfileTileWidget(
                      onTap: () {
                        Get.to(() => const Addresses());
                      },
                      title: 'shipping_address'.tr,
                      icon: SimpleLineIcons.location_pin),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const ServiceCenterPage());
                    },
                    title: 'service_center'.tr,
                    icon: AntDesign.customerservice,
                  ),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const ChatListPage(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 600));
                    },
                    title: 'Hộp chat',
                    icon: Ionicons.chatbubble_ellipses_outline,
                  ),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const SupportPage());
                    },
                    title: 'customer_support'.tr,
                    icon: MaterialIcons.rss_feed,
                  ),
                  ProfileTileWidget(
                    onTap: () {
                      Get.to(() => const SettingsPage(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 900));
                    },
                    title: 'settings'.tr,
                    icon: AntDesign.setting,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              onTap: () {
                controller.logout();
              },
              btnColor: kRed,
              text: 'logout'.tr,
              radius: 0,
            ),
          ])),
        ));
  }
}
