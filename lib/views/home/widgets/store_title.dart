import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/store_model.dart';

class StoreTitle extends StatelessWidget {
  StoreTitle({super.key, required this.store});
  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            height: 70,
            width: width,
            decoration: BoxDecoration(
                color: kOffWhite, borderRadius: BorderRadius.circular(9.r)),
            child: Container(
              padding: EdgeInsets.all(4.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadiusGeometry.all(Radius.circular(12.r)),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 70.w,
                          height: 70.h,
                          child: Image.network(
                            store.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.only(left: 6.w, bottom: 2.h),
                              color: kGray.withOpacity(0.6),
                              height: 16.h,
                              width: width,
                              child: RatingBarIndicator(
                                rating: 5,
                                itemCount: 5,
                                itemBuilder: (context, i) => const Icon(
                                  Icons.star,
                                  color: kSecondary,
                                ),
                                itemSize: 15.h,
                              ),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableText(
                          text: store.title,
                          style: appStyle(11, kDark, FontWeight.w500)),
                      ReusableText(
                          text: "Thời gian vận chuyển: ${store.time}",
                          style: appStyle(11, kGray, FontWeight.w400)),
                      SizedBox(
                        width: width * 0.7,
                        child: Text(
                          store.coords.address,
                          overflow: TextOverflow.ellipsis,
                          style: appStyle(10, kGray, FontWeight.w400),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
              right: 5.w,
              top: 6.h,
              child: Container(
                width: 60.w,
                height: 19.h,
                decoration: BoxDecoration(
                    color: store.isAvailable == true ? kPrimary : kGrayLight),
                child: Center(
                  child: ReusableText(
                      text: store.isAvailable == true ? "Open" : "Closed",
                      style: appStyle(12, kLightWhite, FontWeight.w600)),
                ),
              ))
        ],
      ),
    );
  }
}
