import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserOrders extends StatefulWidget {
  const UserOrders({super.key});

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> with TickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: orderList.length, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOffWhite,
        elevation: 0,
        title: ReusableText(
            text: "My Orders", style: appStyle(14, kPrimary, FontWeight.w600)),
      ),
      body: BackGroundContainer(
        color: kLightWhite,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            OrdersTabs(tabController: _tabController),
            SizedBox(height: 10.h),
            SizedBox(
              height: height * 0.7,
              width: width,
              child: TabBarView(controller: _tabController, children: const [
                Pending(),
                Preparing(),
                Delivering(),
                Delivered(),
                Cancelled()
              ]),
            )
          ],
        ),
      ),
    );
  }
}
