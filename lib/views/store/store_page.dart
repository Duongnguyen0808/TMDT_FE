import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/distance_time.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/services/vietmap_service.dart';
import 'package:appliances_flutter/views/store/widget/row_text.dart';
import 'package:appliances_flutter/views/store/widget/store_bottom_bar.dart';
import 'package:appliances_flutter/views/store/widget/store_menu.dart';
import 'package:appliances_flutter/views/store/widget/store_top_bar.dart';
import 'package:appliances_flutter/views/store/widget/xplore_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:geolocator/geolocator.dart';

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

  DistanceTime? _distanceTime;
  bool _isLoadingDistance = true;

  @override
  void initState() {
    super.initState();
    _loadDistanceAndTime();
  }

  Future<void> _loadDistanceAndTime() async {
    try {
      // Lấy vị trí hiện tại của user
      final position = await Geolocator.getCurrentPosition();

      // Tính khoảng cách và thời gian từ vị trí user đến cửa hàng
      final result = await VietmapService.calculateDistance(
        storeLat: widget.store!.coords.latitude,
        storeLng: widget.store!.coords.longitude,
        customerLat: position.latitude,
        customerLng: position.longitude,
        pricePerKm: 5000,
      );

      if (mounted) {
        setState(() {
          _distanceTime = result;
          _isLoadingDistance = false;
        });
      }
    } catch (e) {
      // Nếu không lấy được vị trí, dùng giá trị mặc định
      if (mounted) {
        setState(() {
          _distanceTime = null;
          _isLoadingDistance = false;
        });
      }
    }
  }

  String _formatTime(double hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes phút';
    } else if (hours < 24) {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      return m > 0 ? '$h giờ $m phút' : '$h giờ';
    } else {
      final days = (hours / 24).floor();
      final remainingHours = (hours % 24).round();
      return remainingHours > 0
          ? '$days ngày $remainingHours giờ'
          : '$days ngày';
    }
  }

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
                  _isLoadingDistance
                      ? const RowText(
                          first: "Khoảng cách đến cửa hàng",
                          second: "Đang tính...",
                        )
                      : RowText(
                          first: "Khoảng cách đến cửa hàng",
                          second: _distanceTime != null
                              ? "${_distanceTime!.distance.toStringAsFixed(1)} km"
                              : "Không xác định",
                        ),
                  SizedBox(
                    height: 3.h,
                  ),
                  _isLoadingDistance
                      ? const RowText(
                          first: "Giá ước tính",
                          second: "Đang tính...",
                        )
                      : RowText(
                          first: "Giá ước tính",
                          second: _distanceTime != null
                              ? usdToVndText(_distanceTime!.price / 1000)
                              : "Không xác định",
                        ),
                  SizedBox(
                    height: 3.h,
                  ),
                  _isLoadingDistance
                      ? const RowText(
                          first: "Thời gian ước tính",
                          second: "Đang tính...",
                        )
                      : RowText(
                          first: "Thời gian ước tính",
                          second: _distanceTime != null
                              ? _formatTime(_distanceTime!.time)
                              : "Không xác định",
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
