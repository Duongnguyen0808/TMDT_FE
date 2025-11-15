import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_category_appliances.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryAppliancesList extends HookWidget {
  const CategoryAppliancesList({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy sản phẩm theo category, nếu không có sẽ fallback lấy tất cả
    final hookResult = useFetchAppliancesByCategory("41007428");
    List<AppliancesModel>? appliancess = hookResult.data;
    final isLoading = hookResult.isLoading;
    return SizedBox(
      width: width,
      height: height,
      child: isLoading
          ? const FoodsListShimmer()
          : Padding(
              padding: EdgeInsets.all(12.h),
              child: ListView(
                children: List.generate(appliancess!.length, (i) {
                  AppliancesModel appliances = appliancess[i];
                  return AppliancesTitle(
                    color: Colors.white,
                    appliances: appliances,
                  );
                }),
              ),
            ),
    );
  }
}
