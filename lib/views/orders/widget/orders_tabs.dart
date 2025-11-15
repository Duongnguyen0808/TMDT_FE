import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';

class OrdersTabs extends StatelessWidget {
  final TabController tabController;
  const OrdersTabs({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    const tabs = ['Chờ xử lý', 'Đang chuẩn bị', 'Đã giao'];

    return TabBar(
      controller: tabController,
      isScrollable: true,
      labelColor: kPrimary,
      unselectedLabelColor: kGray,
      indicatorColor: kPrimary,
      tabs: tabs
          .map((label) => Tab(
                child: ReusableText(
                  text: label,
                  style: appStyle(12, kPrimary, FontWeight.w600),
                ),
              ))
          .toList(),
    );
  }
}

class Pending extends StatelessWidget {
  const Pending({super.key});
  @override
  Widget build(BuildContext context) {
    return const _EmptyOrders(title: 'Chờ xác nhận');
  }
}

class Preparing extends StatelessWidget {
  const Preparing({super.key});
  @override
  Widget build(BuildContext context) {
    return const _EmptyOrders(title: 'Đang chuẩn bị');
  }
}

class Delivering extends StatelessWidget {
  const Delivering({super.key});
  @override
  Widget build(BuildContext context) {
    return const _EmptyOrders(title: 'Đang giao');
  }
}

class Delivered extends StatelessWidget {
  const Delivered({super.key});
  @override
  Widget build(BuildContext context) {
    return const _EmptyOrders(title: 'Đã giao');
  }
}

class Cancelled extends StatelessWidget {
  const Cancelled({super.key});
  @override
  Widget build(BuildContext context) {
    return const _EmptyOrders(title: 'Đã hủy');
  }
}

class _EmptyOrders extends StatelessWidget {
  final String title;
  const _EmptyOrders({required this.title});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: kGrayLight),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng $title',
            style: const TextStyle(color: kGray, fontSize: 16),
          ),
          ReusableText(
              text: title, style: appStyle(14, kGray, FontWeight.w500)),
          ReusableText(
              text: 'Chưa có đơn hàng',
              style: appStyle(12, kGrayLight, FontWeight.normal)),
        ],
      ),
    );
  }
}
