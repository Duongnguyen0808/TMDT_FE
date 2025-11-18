import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_appliances.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/appliances/appliances_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Under200kDealsPage extends HookWidget {
  const Under200kDealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy tất cả sản phẩm rồi lọc theo giá sau giảm <= 200000
    final hookResults = useFetchAppliances("");
    final isLoading = hookResults.isLoading;
    final List<AppliancesModel> all = hookResults.data ?? [];
    final deals = all.where((p) {
      final discountPercent = p.discount; // phần trăm
      final discountedPrice = discountPercent > 0
          ? p.price * (1 - discountPercent / 100)
          : p.price; // nếu không giảm, dùng giá gốc
      return discountedPrice <= 200000;
    }).toList();

    return Scaffold(
      backgroundColor: kSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kSecondary,
        title: ReusableText(
          text: 'Giảm giá dưới 200k',
          style: appStyle(15, kWhite, FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BackGroundContainer(
        color: kLightWhite,
        child: isLoading
            ? const FoodsListShimmer()
            : deals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off, size: 100.h, color: kGray),
                        SizedBox(height: 16.h),
                        ReusableText(
                          text: 'Không có ưu đãi dưới 200k',
                          style: appStyle(16, kGray, FontWeight.w500),
                        ),
                        SizedBox(height: 8.h),
                        ReusableText(
                          text: 'Hãy quay lại sau để xem thêm khuyến mãi!',
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
                      childAspectRatio: 0.72,
                    ),
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      final appliances = deals[index];
                      final discountPercent = appliances.discount;
                      final discountedPrice = discountPercent > 0
                          ? appliances.price * (1 - discountPercent / 100)
                          : appliances.price;
                      return _UnderDealCard(
                        appliances: appliances,
                        discountedPrice: discountedPrice,
                        discountPercent: discountPercent,
                      );
                    },
                  ),
      ),
    );
  }
}

class _UnderDealCard extends StatelessWidget {
  const _UnderDealCard({
    required this.appliances,
    required this.discountedPrice,
    required this.discountPercent,
  });
  final AppliancesModel appliances;
  final double discountedPrice;
  final double discountPercent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => AppliancesPage(appliances: appliances)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: kGray.withOpacity(.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Image.network(
                appliances.imageUrl.isNotEmpty
                    ? appliances.imageUrl.first
                    : 'https://via.placeholder.com/150',
                height: 110.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appliances.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: appStyle(13, kDark, FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    appliances.time,
                    style: appStyle(11, kGray, FontWeight.normal),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (discountPercent > 0)
                        Text(
                          appliances.price.toStringAsFixed(0),
                          style:
                              appStyle(11, kGray, FontWeight.normal).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: 6.w),
                      Text(
                        discountedPrice.toStringAsFixed(0),
                        style: appStyle(15, kPrimary, FontWeight.bold),
                      ),
                    ],
                  ),
                  if (discountPercent > 0)
                    Container(
                      margin: EdgeInsets.only(top: 6.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '-${discountPercent.toInt()}%',
                        style: appStyle(11, kLightWhite, FontWeight.bold),
                      ),
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
