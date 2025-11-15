import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/heading.dart';
import 'package:appliances_flutter/hooks/fetch_hot_deals.dart';
import 'package:appliances_flutter/views/home/widgets/hot_deal_card.dart';
import 'package:appliances_flutter/views/products/all_hot_deals_page.dart';
import 'package:get/get.dart';

class HotDealsWidget extends HookWidget {
  const HotDealsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchHotDeals();
    final hotDeals = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;

    if (isLoading) {
      return const SizedBox.shrink();
    }

    if (hotDeals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.only(left: 12.w, top: 10.h),
      child: Column(
        children: [
          Heading(
            text: "🔥 Ưu đãi Hot",
            onTap: () {
              Get.to(() => const AllHotDealsPage(),
                  transition: Transition.cupertino,
                  duration: const Duration(milliseconds: 900));
            },
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 210.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hotDeals.length > 10 ? 10 : hotDeals.length,
              itemBuilder: (context, index) {
                return HotDealCard(appliance: hotDeals[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
