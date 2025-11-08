import 'package:appliances_flutter/common/app_style.dart' as styles;
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/controllers/orders_controller.dart' as oc;
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:get/get.dart';

class PaymentFailed extends StatelessWidget {
  const PaymentFailed({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.put(oc.OrdersController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            // Quay về trang đặt hàng để chọn lại phương thức
            orderController.setPaymentUrl = '';
            Get.back();
          },
          child: const Icon(
            AntDesign.closecircleo,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/No.png",
              color: Colors.red,
            ),
            ReusableText(
                text: "Thanh toán thất bại",
                style: styles.appStyle(28, Colors.black, FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                orderController.setPaymentUrl = '';
                Get.back();
              },
              child: const Text('Quay lại chọn phương thức'),
            )
          ],
        ),
      ),
    );
  }
}
