import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_orders.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/views/orders/widget/client_order_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Cancelled extends HookWidget {
  const Cancelled({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchOrders('Cancelled', 'Completed');

    List<ClientOrders> orders = hookResults.data;
    final isLoading = hookResults.isLoading;

    if (isLoading) {
      return const FoodsListShimmer();
    }

    return SizedBox(
      height: height * 0.8,
      child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            if (order.orderItems.isEmpty) {
              return const SizedBox.shrink();
            }
            final item = order.orderItems[0];
            if (item.appliancesId.imageUrl.isEmpty) {
              return const SizedBox.shrink();
            }
            return ClientOrderTile(
              appliances: item,
              fullOrder: order,
            );
          }),
    );
  }
}
