import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/shimmers/nearby_shimmer.dart';
import 'package:appliances_flutter/hooks/fetch_store.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/home/widgets/store_widget.dart';

class FeaturedProductsList extends HookWidget {
  const FeaturedProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchStore("41007428");
    List<StoreModel>? stores = hookResults.data;
    final isLoading = hookResults.isLoading;

    return isLoading
        ? const NearbyShimmer()
        : Container(
            height: 190.h,
            padding: EdgeInsets.only(left: 12.w, top: 10.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(stores!.length, (i) {
                StoreModel store = stores[i];
                return StoreWidget(
                    image: store.imageUrl,
                    logo: store.logoUrl,
                    title: store.title,
                    time: store.time,
                    rating: "7457");
              }),
            ),
          );
  }
}
