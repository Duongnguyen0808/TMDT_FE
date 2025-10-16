import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      this.keyboardType,
      this.controller,
      required this.onEditingComplete,
      this.obscureText,
      this.suffixIcon,
      this.validator,
      this.prefixIcon,
      this.hintText});

  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function() onEditingComplete;
  final bool? obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(6.h),
        padding: EdgeInsets.only(left: 6.h),
        decoration: BoxDecoration(
          border: Border.all(color: kGray, width: 0.4),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText ?? false,
          onEditingComplete: onEditingComplete,
          cursorHeight: 20.h,
          style: appStyle(11, kDark, FontWeight.normal),
          validator: validator,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: appStyle(11, kDark, FontWeight.normal),
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon),
        ));
  }
}
