import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/shimmers/shimmer_widget.dart';

class CatergoriesShimmer extends StatelessWidget {
  const CatergoriesShimmer(
      {super.key, this.itemCount = 8}); // cho phép truyền số lượng

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 10),
      height: 75.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount, // không fix cứng nữa
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Column(
              children: [
                ShimmerWidget(
                  shimmerWidth: 70.w,
                  shimmerHieght: 60.h,
                  shimmerRadius: 12,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
