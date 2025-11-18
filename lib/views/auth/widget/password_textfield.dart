import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/password_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    this.controller,
    this.focusNode,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final passwordController = Get.put(PasswordController());
    return Obx(() => TextFormField(
          cursorColor: kDark,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.visiblePassword,
          controller: controller,
          focusNode: focusNode,
          obscureText: passwordController.password,
          validator: (value) {
            final v = value ?? '';
            if (v.isEmpty) {
              return "Vui lòng nhập mật khẩu";
            }
            if (v.length < 8) {
              return "Mật khẩu phải từ 8 ký tự";
            }
            final hasLetter = RegExp(r"[A-Za-z]").hasMatch(v);
            final hasNumber = RegExp(r"\d").hasMatch(v);
            if (!hasLetter || !hasNumber) {
              return "Mật khẩu cần chữ và số";
            }
            return null;
          },
          style: appStyle(12, kDark, FontWeight.normal),
          decoration: InputDecoration(
              hintText: "Mật khẩu",
              prefixIcon: const Icon(
                CupertinoIcons.lock_circle,
                size: 26,
                color: kGrayLight,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  passwordController.setPassword = !passwordController.password;
                },
                child: Icon(
                  passwordController.password
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 26,
                  color: kGrayLight,
                ),
              ),
              isDense: true,
              contentPadding: EdgeInsets.all(6.h),
              hintStyle: appStyle(12, kGray, FontWeight.normal),
              errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kRed, width: .5),
                  borderRadius: BorderRadius.all(Radius.circular(12.r))),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kPrimary, width: .5),
                  borderRadius: BorderRadius.all(Radius.circular(12.r))),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kRed, width: .5),
                  borderRadius: BorderRadius.all(Radius.circular(12.r))),
              disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kGray, width: .5),
                  borderRadius: BorderRadius.all(Radius.circular(12.r))),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kPrimary, width: .5),
                  borderRadius: BorderRadius.all(Radius.circular(12.r))),
              border: OutlineInputBorder(
                  borderSide: const BorderSide(color: kPrimary, width: .5),
                  borderRadius: BorderRadius.all(Radius.circular(12.r)))),
        ));
  }
}
