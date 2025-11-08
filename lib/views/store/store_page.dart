import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/store/widget/row_text.dart';
import 'package:appliances_flutter/views/store/widget/store_bottom_bar.dart';
import 'package:appliances_flutter/views/store/widget/store_menu.dart';
import 'package:appliances_flutter/views/store/widget/store_top_bar.dart';
import 'package:appliances_flutter/views/store/widget/xplore_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/utils/currency.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key, required this.store});

  final StoreModel? store;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with TickerProviderStateMixin {
  late TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kLightWhite,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 230.h,
                  width: width,
                  child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.store?.imageUrl ?? ""),
                ),
                Positioned(
                    bottom: 0, child: StoreBottomBar(store: widget.store)),
                Positioned(
                    top: 40.h,
                    left: 0,
                    right: 0,
                    child: StoreTopBar(store: widget.store))
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  const RowText(
                    first: "Khoảng cách đến cửa hàng",
                    second: "2.7 km",
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  RowText(
                    first: "Giá ước tính",
                    second: usdToVndText(2.7),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const RowText(
                    first: "Thời gian ước tính",
                    second: "30 phút",
                  ),
                  const Divider(
                    thickness: 0.7,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                height: 25.h,
                width: width,
                decoration: BoxDecoration(
                    color: kOffWhite,
                    borderRadius: BorderRadius.circular(25.r)),
                child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(25.r)),
                    labelPadding: EdgeInsets.zero,
                    labelColor: kLightWhite,
                    labelStyle: appStyle(12, kLightWhite, FontWeight.normal),
                    unselectedLabelColor: kGrayLight,
                    tabs: [
                      Tab(
                        child: SizedBox(
                          width: width / 2,
                          height: 25,
                          child: const Center(
                            child: Text("Thực đơn"),
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          width: width / 2,
                          height: 25,
                          child: const Center(
                            child: Text("Khám phá"),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: SizedBox(
                height: height,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    StoreMenu(
                      storeId: widget.store!.id,
                    ),
                    XploreWidget(
                      code: widget.store!.code,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
