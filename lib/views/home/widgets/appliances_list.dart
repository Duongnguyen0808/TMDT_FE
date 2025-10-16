import 'package:appliances_flutter/common/shimmers/nearby_shimmer.dart';
import 'package:appliances_flutter/hooks/fetch_appliances.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppliancesList extends HookWidget {
  const AppliancesList({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchAppliances("41007428");
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
                    image: appliances.imageUrl[0],
                    title: appliances.title,
                    time: appliances.time,
                    price: appliances.price.toStringAsFixed(2));
              }),
            ),
    );
  }
}
