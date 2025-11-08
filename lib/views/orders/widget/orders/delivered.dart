import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_orders.dart';
import 'package:appliances_flutter/models/client_orders.dart';
import 'package:appliances_flutter/views/orders/widget/client_order_title.dart';
import 'package:appliances_flutter/views/orders/widget/order_item_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';


class Delivered extends HookWidget {
  const Delivered({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResults = useFetchOrders('Delivered', 'Completed');

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
            final item = orders[i].orderItems.isNotEmpty
                ? orders[i].orderItems[0]
                : null;
            if (item == null) {
              return const SizedBox.shrink();
            }
            return ClientOrderTile(appliances: toOrderModelItem(item));
          }),
    );
  }
}
