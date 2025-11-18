import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/models/login_response.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  LoginResponse? user;

  @override
  void initState() {
    super.initState();
    final login = Get.put(LoginController());
    user = login.getUserInfo();
    if (user != null) {
      _usernameCtrl.text = user!.username;
      _phoneCtrl.text = user!.phone;
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Backend hiện chưa có endpoint cập nhật hồ sơ (username/phone) ngoại trừ verify.
    // Tạm thời hiển thị thông báo.
    Get.snackbar('Chưa hỗ trợ', 'Chức năng cập nhật hồ sơ sẽ sớm khả dụng',
        backgroundColor: kPrimary, colorText: kLightWhite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
        title: ReusableText(
          text: 'Chỉnh sửa hồ sơ',
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: kOffWhite),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReusableText(
                text: 'Tên hiển thị',
                style: appStyle(13, kDark, FontWeight.w600)),
            SizedBox(height: 6.h),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                filled: true,
                fillColor: kLightWhite,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            SizedBox(height: 16.h),
            ReusableText(
                text: 'Số điện thoại',
                style: appStyle(13, kDark, FontWeight.w600)),
            SizedBox(height: 6.h),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                filled: true,
                fillColor: kLightWhite,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: _save,
                child: ReusableText(
                  text: 'Lưu thay đổi',
                  style: appStyle(16, kLightWhite, FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
