// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    this.onTap,
    this.btnWidth,
    this.btnHeight,
    this.btnColor,
    this.radius,
    required this.text,
  }) : super(key: key);

  final void Function()? onTap;
  final double? btnWidth;
  final double? btnHeight;
  final Color? btnColor;
  final double? radius;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: btnWidth ?? width,
        height: btnHeight ?? 28.h,
        decoration: BoxDecoration(
          color: btnColor ?? kPrimary,
          borderRadius: BorderRadius.circular(radius ?? 9.r),
        ),
        child: Center(
          child: ReusableText(
              text: text, style: appStyle(12, kLightWhite, FontWeight.w600)),
        ),
      ),
    );
  }
}
