import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_all_store.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/home/widgets/store_title.dart';

class FeaturedProductsPage extends HookWidget {
  const FeaturedProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchAllStore("41007428");
    List<StoreModel>? stores = hookResults.data;
    final isLoading = hookResults.isLoading;
    return Scaffold(
        backgroundColor: kSecondary,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kSecondary,
          title: ReusableText(
              text: "Sản phẩm nổi bật",
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
                    children: List.generate(stores!.length, (i) {
                      var store = stores[i];
                      return StoreTitle(
                        store: store,
                      );
                    }),
                  ),
                ),
        ));
  }
}
