import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/search_controller.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchAppliancesController());
    final results = controller.searchResults ?? [];
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Text(
            "Không tìm thấy sản phẩm phù hợp",
            style: appStyle(12, kGray, FontWeight.w500),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.h, 0),
      height: height,
      child: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, i) {
            AppliancesModel appliances = results[i];
            return AppliancesTitle(appliances: appliances);
          }),
    );
  }
}
