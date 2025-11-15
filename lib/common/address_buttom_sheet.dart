import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/custom_button.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/views/profile/shipping_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

Future<dynamic> showAddressSheet(BuildContext context) {
  return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          width: width,
          decoration: BoxDecoration(
            image: const DecorationImage(
                image: AssetImage("assets/images/restaurant_bk.png"),
                fit: BoxFit.fill,
                opacity: 0.3),
            color: kLightWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
                  ReusableText(
                      text: "Thêm Địa Chỉ",
                      style: appStyle(18, kPrimary, FontWeight.w600)),
                  SizedBox(height: 16.h),
                  ...List.generate(reasonsToAddAddress.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: kPrimary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              reasonsToAddAddress[index],
                              textAlign: TextAlign.justify,
                              style:
                                  appStyle(11, kGrayLight, FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  CustomButton(
                    text: "Thêm địa chỉ ngay",
                    btnHeight: 40.h,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ShippingAddress());
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
      });
}
