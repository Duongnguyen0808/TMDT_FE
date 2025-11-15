import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              "enter_keyword".tr,
              style: appStyle(12, kGray, FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 80.h),
            child: LottieBuilder.asset(
              "assets/anime/delivery.json",
              width: width,
              height: height / 3,
            ),
          ),
        ],
      ),
    );
  }
}
