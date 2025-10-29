import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/phone_verification_controller.dart';
import 'package:appliances_flutter/services/verification_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:appliances_flutter/vendor/phone_otp_verification/phone_verification.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  VerificationService _verificationService = VerificationService();

  String _verificationId = '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneVerificationController());
    return Obx(() => controller.isLoading == false
        ? PhoneVerification(
            isFirstPage: false,
            enableLogo: false,
            themeColor: kPrimary,
            backgroundColor: kLightWhite,
            initialPageText: "Xác minh số điện thoại",
            initialPageTextStyle: appStyle(20, kPrimary, FontWeight.bold),
            textColor: kDark,
            onSend: (String value) {
              final normalized = value.trim().replaceAll(' ', '');
              controller.setPhoneNumber =
                  normalized.startsWith('+') ? normalized : '+84$normalized';
              _verifyPhoneNumber(controller.phone);
            },
            onVerification: (String value) {
              _submitVerificationCode(value);
            },
          )
        : Container(
            color: kLightWhite,
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ));
  }

  void _verifyPhoneNumber(String phoneNumber) async {
    final controller = Get.put(PhoneVerificationController());

    await _verificationService.verifyPhoneNumber(controller.phone,
        codeSent: (String verificationId, int? resendToken) {
      setState(() {
        _verificationId = verificationId;
      });
    });
  }

  void _submitVerificationCode(String code) async {
    if (_verificationId.isEmpty) {
      Get.snackbar('Vui lòng chờ', 'Đang gửi mã, thử lại sau vài giây',
          colorText: kLightWhite, backgroundColor: kRed);
      return;
    }
    final normalized = code.trim().replaceAll(' ', '');
    await _verificationService.verifySmsCode(_verificationId, normalized);
  }
}
