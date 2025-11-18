import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/change_password_controller.dart';
import 'package:appliances_flutter/views/auth/widget/password_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Đổi mật khẩu', style: appStyle(16, kDark, FontWeight.w600)),
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
        child: ListView(
          children: [
            ReusableText(
              text: 'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới',
              style: appStyle(14, kGray, FontWeight.w400),
            ),
            SizedBox(height: 12.h),
            PasswordTextField(controller: _oldCtrl),
            SizedBox(height: 12.h),
            PasswordTextField(controller: _newCtrl),
            SizedBox(height: 12.h),
            PasswordTextField(controller: _confirmCtrl),
            SizedBox(height: 16.h),
            Obx(() => CustomButton(
                  text: controller.isLoading.value
                      ? 'Đang lưu...'
                      : 'Lưu thay đổi',
                  btnHeight: 40.h,
                  btnWidth: width,
                  onTap: controller.isLoading.value
                      ? null
                      : () async {
                          if (_newCtrl.text.length < 8 ||
                              _newCtrl.text != _confirmCtrl.text) {
                            Get.snackbar('Cảnh báo',
                                'Mật khẩu mới không hợp lệ hoặc không khớp',
                                colorText: Colors.white, backgroundColor: kRed);
                            return;
                          }
                          final ok = await controller.changePassword(
                            oldPassword: _oldCtrl.text,
                            newPassword: _newCtrl.text,
                          );
                          if (ok) {
                            Get.back();
                          }
                        },
                )),
          ],
        ),
      ),
    );
  }
}
