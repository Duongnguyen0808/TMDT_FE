import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_hot_deals.dart';
import 'package:appliances_flutter/views/home/widgets/hot_deal_card.dart';
import 'package:get/get.dart';

class AllHotDealsPage extends HookWidget {
  const AllHotDealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchHotDeals();
    // Danh sách ưu đãi nhận từ API (có thể chứa mọi mức giá)
    final rawHotDeals = hookResult.data ?? [];
    // Lọc chỉ các sản phẩm có giá sau giảm <= 200,000đ
    final hotDeals = rawHotDeals.where((a) {
      final discount = a.discount; // %
      final original = a.price; // giá gốc
      final discounted = original * (1 - (discount / 100));
      return discounted <= 200000; // ngưỡng 200k
    }).toList();
    final isLoading = hookResult.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            SizedBox(width: 8.w),
            ReusableText(
              text: 'Ưu đãi Hot',
              style: appStyle(18, kLightWhite, FontWeight.w600),
            ),
          ],
        ),
      ),
      body: BackGroundContainer(
        color: kOffWhite,
        child: isLoading
            ? const FoodsListShimmer()
            : hotDeals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 100.h,
                          color: kGray,
                        ),
                        SizedBox(height: 16.h),
                        ReusableText(
                          text: 'Không có ưu đãi dưới 200k',
                          style: appStyle(16, kGray, FontWeight.w500),
                        ),
                        SizedBox(height: 8.h),
                        ReusableText(
                          text: 'Hãy quay lại sau hoặc xem ưu đãi khác',
                          style: appStyle(13, kGray, FontWeight.normal),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: hotDeals.length,
                    itemBuilder: (context, index) {
                      return HotDealCard(appliance: hotDeals[index]);
                    },
                  ),
      ),
    );
  }
}
