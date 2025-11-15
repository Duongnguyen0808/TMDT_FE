import 'package:appliances_flutter/models/client_orders.dart' as client;
import 'package:appliances_flutter/models/order_model.dart' as model;

model.OrderItem toOrderModelItem(client.OrderItem item) {
  return model.OrderItem(
    appliancesId: model.AppliancesId(
      id: item.appliancesId.id,
      title: item.appliancesId.title,
      rating: item.appliancesId.rating,
      imageUrl: item.appliancesId.imageUrl,
      time: item.appliancesId.time,
    ),
    quantity: item.quantity,
    price: item.price,
    additives: item.additives,
    instructions: item.instructions,
    id: item.id,
  );
}
