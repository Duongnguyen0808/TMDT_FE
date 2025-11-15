import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:appliances_flutter/views/orders/widget/orders_tabs.dart';
// Import các widget đơn hàng theo trạng thái thực tế
import 'package:appliances_flutter/views/orders/widget/orders/pending.dart'
    as ord_pending;
import 'package:appliances_flutter/views/orders/widget/orders/preparing.dart'
    as ord_preparing;
import 'package:appliances_flutter/views/orders/widget/orders/delivered.dart'
    as ord_delivered;

class UserOrders extends StatefulHookWidget {
  const UserOrders({super.key});

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> with TickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kLightWhite,
          ),
        ),
        title: ReusableText(
            text: "Đơn hàng của tôi",
            style: appStyle(18, kLightWhite, FontWeight.w600)),
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
                ord_pending.Pending(),
                ord_preparing.Preparing(),
                ord_delivered.Delivered(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
