import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/cart_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:appliances_flutter/utils/currency.dart';

import 'package:get/get.dart';

class OrderTile extends StatelessWidget {
  OrderTile({super.key, required this.appliances, this.color});

  final AppliancesModel appliances;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          height: 70.h,
          width: width,
          decoration: BoxDecoration(
              color: color ?? kOffWhite,
              borderRadius: BorderRadius.circular(9.r)),
          child: Container(
            padding: EdgeInsets.all(4.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 70.w,
                        height: 70.h,
                        child: Image.network(
                          appliances.imageUrl[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.only(left: 6.w, bottom: 2.h),
                          color: kGray.withOpacity(0.6),
                          height: 16.h,
                          width: 70.w,
                          child: RatingBarIndicator(
                            rating: 5,
                            itemCount: 5,
                            itemBuilder: (context, i) => const Icon(
                              Icons.star,
                              color: kSecondary,
                            ),
                            itemSize: 15.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: appliances.title,
                      style: appStyle(11, kDark, FontWeight.w600),
                      maxLines: 1,
                    ),
                    ReusableText(
                      text: "Thời gian giao hàng: ${appliances.time}",
                      style: appStyle(11, kGray, FontWeight.w400),
                    ),
                    SizedBox(
                      width: width * 0.7,
                      height: 15.h,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: appliances.additives.length,
                          itemBuilder: (context, i) {
                            Additive additive = appliances.additives[i];
                            return Container(
                              margin: EdgeInsets.only(right: 5.w),
                              decoration: BoxDecoration(
                                color: kSecondaryLight,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(9.r),
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(2.h),
                                  child: ReusableText(
                                      text: additive.title,
                                      style:
                                          appStyle(8, kGray, FontWeight.w400)),
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          right: 6.w,
          top: 6.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  var data = CartRequest(
                      productId: appliances.id,
                      additives: [],
                      quantity: 1,
                      totalPrice: appliances.price);

                  String cart = cartRequestToJson(data);
                  controller.addToCart(cart);
                },
                child: Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Center(
                    child: Icon(
                      MaterialCommunityIcons.cart_plus,
                      size: 16.h,
                      color: kLightWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                constraints: BoxConstraints(minWidth: 100.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                height: 22.h,
                decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                    border: Border.all(color: Colors.white24, width: 1)),
                child: Center(
                  child: ReusableText(
                      text: usdToVndText(appliances.price),
                      style: appStyle(12, kLightWhite, FontWeight.bold)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
