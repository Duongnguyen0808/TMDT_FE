// ignore_for_file: unnecessary_import, prefer_const_constructors

import 'package:appliances_flutter/common/shimmers/nearby_shimmer.dart';
import 'package:appliances_flutter/hooks/fetch_appliances.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/appliances/appliances_page.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

class AppliancesList extends HookWidget {
  final bool useRecommendation; // true = random, false = all

  const AppliancesList({super.key, this.useRecommendation = false});

  @override
  Widget build(BuildContext context) {
    // useRecommendation=true: lấy random (gợi ý), false: lấy tất cả
    final hookResults =
        useFetchAppliances(useRecommendation ? "recommendation" : "");
    List<AppliancesModel>? appliancess = hookResults.data;
    final isLoading = hookResults.isLoading;
    return Container(
      height: 184.h,
      padding: EdgeInsets.only(left: 12.w, top: 10.h),
      child: isLoading
          ? NearbyShimmer()
          : ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(appliancess!.length, (i) {
                var appliances = appliancess[i];
                return AppliancesWidget(
                    onTap: () {
                      Get.to(() => AppliancesPage(appliances: appliances));
                    },
                    image: appliances.imageUrl[0],
                    title: appliances.title,
                    time: appliances.time,
                    price: appliances.price.toString()); // Truyền số thuần
              }),
            ),
    );
  }
}
