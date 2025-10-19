import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/store/rating_page.dart';
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
            child: RatingBarIndicator(
                itemCount: 5,
                itemSize: 18,
                rating: store?.rating.toDouble() ?? 0.0,
                itemBuilder: (context, i) => const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    )),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: CustomButton(
                onTap: () {
                  Get.to(() => const RatingPage());
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
