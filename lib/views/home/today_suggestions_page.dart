import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_appliances.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TodaySuggestionsPage extends HookWidget {
  const TodaySuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchAppliances("41007428");
    List<AppliancesModel>? appliancess = hookResults.data;
    final isLoading = hookResults.isLoading;
    return Scaffold(
        backgroundColor: kSecondary,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kSecondary,
          title: ReusableText(
              text: "Gợi ý hôm nay",
              style: appStyle(15, kWhite, FontWeight.bold)),
          centerTitle: true,
        ),
        body: BackGroundContainer(
          color: Colors.white,
          child: isLoading
              ? FoodsListShimmer()
              : Padding(
                  padding: EdgeInsets.all(12.h),
                  child: ListView(
                    children: List.generate(appliancess!.length, (i) {
                      var appliances = appliancess[i];
                      return AppliancesTitle(
                        appliances: appliances,
                      );
                    }),
                  ),
                ),
        ));
  }
}
