import 'package:appliances_flutter/models/client_orders.dart';

/// Base visibility rule for "Đã nhận hàng" actions on the customer app.
bool canCustomerConfirmReceipt(ClientOrders order) {
  if (order.orderStatus == 'Cancelled') return false;

  final shopStatus = (order.shopDeliveryConfirmStatus ?? '').toLowerCase();
  if (shopStatus == 'confirmed') return false;

  final orderPhase = (order.orderStatus).toLowerCase();
  final logisticPhase = (order.logisticStatus ?? '').toLowerCase();

  if (orderPhase == 'delivered' || logisticPhase == 'delivered') {
    return true;
  }

  final isDriverOnRoute = orderPhase == 'delivering' ||
      orderPhase == 'pickedup' ||
      logisticPhase == 'delivering' ||
      logisticPhase == 'pickedup';

  return isDriverOnRoute;
}
