// ignore_for_file: depend_on_referenced_packages

import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/custom_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/verification_controller.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationController());
    final loginController = Get.put(LoginController());
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        title: ReusableText(
            text: "Vui lòng xác minh tài khoản của bạn",
            style: appStyle(12, kGray, FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomContainer(
          color: Colors.white,
          containerContent: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: height,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Lottie.asset("assets/anime/delivery.json"),
                  SizedBox(
                    height: 10.h,
                  ),
                  ReusableText(
                      text: "Xác minh tài khoản của bạn",
                      style: appStyle(20, kPrimary, FontWeight.w600)),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                      "Nhập mã 6 chữ số được gửi đến email của bạn, nếu bạn không thấy mã, vui lòng kiểm tra thư mục thư rác. ",
                      textAlign: TextAlign.justify,
                      style: appStyle(10, kGray, FontWeight.normal)),
                  SizedBox(
                    height: 20.h,
                  ),
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: kPrimary,
                    borderWidth: 2.0,
                    textStyle: appStyle(17, kDark, FontWeight.w600),
                    onCodeChanged: (String code) {},
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    onSubmit: (String verificationCode) {
                      controller.setCode = verificationCode;
                    },
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  CustomButton(
                    text: "Xác minh tài khoản",
                    onTap: () {
                      controller.verificationFunction();
                    },
                    btnHeight: 35.h,
                    btnWidth: width,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomButton(
                    text: "Đăng xuất",
                    onTap: () {
                      loginController.logout();
                    },
                    btnHeight: 35.h,
                    btnWidth: width,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
