import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/store/rating_page.dart';
import 'package:appliances_flutter/views/store/reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StoreBottomBar extends StatelessWidget {
  const StoreBottomBar({
    super.key,
    required this.store,
  });

  final StoreModel? store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      width: width,
      height: 40.h,
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                if (store != null) {
                  Get.to(() => ReviewsPage(
                        productId: store!.id,
                        ratingType: 'Store',
                        productName: store!.title,
                      ));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBarIndicator(
                      itemCount: 5,
                      itemSize: 16,
                      rating: store?.rating.toDouble() ?? 0.0,
                      itemBuilder: (context, i) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          )),
                  SizedBox(height: 2.h),
                  Text(
                    '${store?.ratingCount ?? 0} đánh giá',
                    style: appStyle(10, kDark, FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: CustomButton(
                onTap: () {
                  if (store != null) {
                    Get.to(() => RatingPage(
                          productId: store!.id,
                          ratingType: 'Store',
                        ));
                  } else {
                    Get.snackbar(
                      'Lỗi',
                      'Không tìm thấy thông tin cửa hàng',
                      backgroundColor: kRed,
                      colorText: kLightWhite,
                    );
                  }
                },
                btnColor: kSecondary,
                btnHeight: 30.h,
                text: "Đánh giá cửa hàng"),
          ),
        ],
      ),
    );
  }
}
