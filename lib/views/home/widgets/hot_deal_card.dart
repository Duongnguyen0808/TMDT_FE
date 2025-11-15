import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/views/appliances/appliances_page.dart';

class HotDealCard extends StatelessWidget {
  final AppliancesModel appliance;

  const HotDealCard({super.key, required this.appliance});

  @override
  Widget build(BuildContext context) {
    final discount = appliance.discount;
    final originalPrice = appliance.price;
    final discountedPrice = originalPrice * (1 - discount / 100);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => AppliancesPage(appliances: appliance),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 900),
        );
      },
      child: Container(
        width: 180.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: kLightWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: kGray.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with discount badge
            Stack(
              children: [
                Container(
                  height: 120.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: Image.network(
                      appliance.imageUrl[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: kGrayLight,
                          child: Icon(Icons.image_not_supported, size: 40.sp),
                        );
                      },
                    ),
                  ),
                ),
                // Discount badge
                if (discount > 0)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.red.shade700],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ReusableText(
                        text: "-${discount.toInt()}%",
                        style: appStyle(12, kLightWhite, FontWeight.bold),
                      ),
                    ),
                  ),
                // Hot badge
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 12.sp, color: kLightWhite),
                        SizedBox(width: 2.w),
                        ReusableText(
                          text: "HOT",
                          style: appStyle(10, kLightWhite, FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Product info
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                    text: appliance.title,
                    style: appStyle(13, kDark, FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12.sp, color: kGray),
                      SizedBox(width: 4.w),
                      ReusableText(
                        text: appliance.time,
                        style: appStyle(10, kGray, FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Price
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Original price
                            if (discount > 0)
                              ReusableText(
                                text: formatVND(originalPrice),
                                style: appStyle(11, kGray, FontWeight.normal)
                                    .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            // Discounted price
                            ReusableText(
                              text: formatVND(discountedPrice),
                              style: appStyle(15, kPrimary, FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
