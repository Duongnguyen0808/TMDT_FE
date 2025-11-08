import 'dart:async';

import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/orders_controller.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:get/get.dart';

class Successful extends StatelessWidget {
  const Successful({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.put(OrdersController());
    Timer(const Duration(seconds: 3), () {
      orderController.setIcon = true;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 10),
            child: GestureDetector(
                onTap: () {
                  Get.offAll(() => MainScreen());
                },
                child: const Icon(
                  AntDesign.closecircle,
                  color: kGrayLight,
                )),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/restaurant_bk.png"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: height * 0.3.h,
                width: width - 40,
                decoration: BoxDecoration(
                    color: kOffWhite,
                    borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      ReusableText(
                          text: orderController.selectedMethod == 'COD'
                              ? "Đặt hàng thành công"
                              : "Thanh toán thành công",
                          style: appStyle(13, kGray, FontWeight.normal)),
                      const Divider(
                        thickness: .2,
                        color: kGray,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          children: [
                            TableRow(children: [
                              ReusableText(
                                  text: "Mã đơn hàng",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                              ReusableText(
                                  text: orderController.getOrderId,
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                            ]),
                            TableRow(children: [
                              ReusableText(
                                  text: "Mã thanh toán",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                              ReusableText(
                                  text: "113456",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                            ]),
                            TableRow(children: [
                              ReusableText(
                                  text: "Phương thức thanh toán",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                              ReusableText(
                                  text: orderController.selectedMethod.isEmpty
                                      ? ""
                                      : orderController.selectedMethod,
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                            ]),
                            TableRow(children: [
                              ReusableText(
                                  text: "Số tiền",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                              ReusableText(
                                  text: usdToVndText(
                                      orderController.order!.grandTotal),
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                            ]),
                            TableRow(children: [
                              ReusableText(
                                  text: "Cửa hàng",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                              ReusableText(
                                  text: orderController.order?.storeId ?? '',
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                            ]),
                            TableRow(children: [
                              ReusableText(
                                  text: "Ngày",
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                              ReusableText(
                                  text: DateTime.now()
                                      .toString()
                                      .substring(0, 10),
                                  style:
                                      appStyle(11, kGray, FontWeight.normal)),
                            ]),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Icon(
                    size: 35,
                    AntDesign.checkcircle,
                    color: kPrimary,
                  )),
              Positioned(
                top: 52,
                left: 0,
                child: Container(
                    height: 10.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r)),
                    )),
              ),
              Positioned(
                top: 52,
                right: 0,
                child: Container(
                    height: 10.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          bottomLeft: Radius.circular(20.r)),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
