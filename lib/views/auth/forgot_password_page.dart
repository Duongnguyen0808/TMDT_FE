import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/forgot_password_controller.dart';
import 'package:appliances_flutter/views/auth/widget/email_textfield.dart';
import 'package:appliances_flutter/views/auth/widget/password_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Quên mật khẩu', style: appStyle(16, kDark, FontWeight.w600)),
        backgroundColor: kOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: kOffWhite,
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!sent) ...[
                ReusableText(
                  text: 'Nhập email để nhận OTP',
                  style: appStyle(14, kGray, FontWeight.w400),
                ),
                SizedBox(height: 12.h),
                EmailTextField(
                  hintText: 'Email',
                  controller: _emailCtrl,
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: kGrayLight),
                ),
                SizedBox(height: 16.h),
                Obx(() => CustomButton(
                      text: controller.isSending.value
                          ? 'Đang gửi...'
                          : 'Gửi OTP',
                      btnHeight: 40.h,
                      btnWidth: width,
                      onTap: controller.isSending.value
                          ? null
                          : () async {
                              if (_emailCtrl.text.isEmpty) return;
                              final ok = await controller
                                  .sendOtp(_emailCtrl.text.trim());
                              if (ok) {
                                setState(() => sent = true);
                              }
                            },
                    )),
              ] else ...[
                ReusableText(
                  text: 'Nhập OTP và mật khẩu mới',
                  style: appStyle(14, kGray, FontWeight.w400),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Mã OTP',
                    isDense: true,
                    contentPadding: EdgeInsets.all(10.h),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: kPrimary, width: .5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: kPrimary, width: .8),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                PasswordTextField(controller: _newPassCtrl),
                SizedBox(height: 12.h),
                PasswordTextField(controller: _confirmPassCtrl),
                SizedBox(height: 16.h),
                Obx(() => CustomButton(
                      text: controller.isResetting.value
                          ? 'Đang đặt lại...'
                          : 'Đặt lại mật khẩu',
                      btnHeight: 40.h,
                      btnWidth: width,
                      onTap: controller.isResetting.value
                          ? null
                          : () async {
                              if (_otpCtrl.text.isEmpty ||
                                  _newPassCtrl.text.length < 8 ||
                                  _newPassCtrl.text != _confirmPassCtrl.text) {
                                Get.snackbar('Cảnh báo',
                                    'Vui lòng nhập hợp lệ và xác nhận mật khẩu',
                                    colorText: Colors.white,
                                    backgroundColor: kRed);
                                return;
                              }
                              final ok = await controller.resetPassword(
                                otp: _otpCtrl.text.trim(),
                                newPassword: _newPassCtrl.text,
                              );
                              if (ok) {
                                Get.back();
                              }
                            },
                    )),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
