import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_orders.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/views/orders/widget/client_order_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Pending extends HookWidget {
  const Pending({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchOrders('Pending');

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
            // Kiểm tra appliancesId có imageUrl không rỗng
            if (item.appliancesId.imageUrl.isEmpty) {
              return const SizedBox.shrink();
            }
            return ClientOrderTile(
              appliances: item,
              fullOrder: order,
              onCancelled: hookResults.refetch != null
                  ? () => hookResults.refetch!()
                  : null,
            );
          }),
    );
  }
}
