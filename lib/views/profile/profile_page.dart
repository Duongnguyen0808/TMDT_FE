// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison, unused_local_variable

import 'package:appliances_flutter/common/profile_app_bar.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/views/auth/login_redirect.dart';
import 'package:appliances_flutter/views/auth/verification_page.dart';
import 'package:appliances_flutter/views/profile/addresses_page.dart';

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
                        Get.to(() => const UserOrders(),
                            transition: Transition.cupertino,
                            duration: const Duration(milliseconds: 900));
                      },
                      title: "Đơn hàng của tôi",
                      icon: Icons.shopping_cart),
                  ProfileTileWidget(
                    onTap: () {},
                    title: "Địa điểm yêu thích",
                    icon: Ionicons.heart_outline,
                  ),
                  ProfileTileWidget(
                    onTap: () {},
                    title: "Đánh giá của tôi",
                    icon: Ionicons.chatbubbles_outline,
                  ),
                  ProfileTileWidget(
                    onTap: () {},
                    title: "Phiếu giảm giá",
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
                      title: "Địa chỉ giao hàng",
                      icon: SimpleLineIcons.location_pin),
                  ProfileTileWidget(
                    onTap: () {},
                    title: "Trung tâm dịch vụ",
                    icon: AntDesign.customerservice,
                  ),
                  ProfileTileWidget(
                    onTap: () {},
                    title: "Hỗ trợ khách hàng",
                    icon: MaterialIcons.rss_feed,
                  ),
                  ProfileTileWidget(
                    onTap: () {},
                    title: "Cài đặt",
                    icon: AntDesign.setting,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              onTap: () {},
              btnColor: kRed,
              text: "Đăng xuất",
              radius: 0,
            ),
          ])),
        ));
  }
}
