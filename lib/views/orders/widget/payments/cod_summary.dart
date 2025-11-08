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

class CodSummary extends StatelessWidget {
  const CodSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.put(OrdersController());
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
          child: Container(
            height: height * 0.35.h,
            width: width - 40,
            decoration: BoxDecoration(
                color: kOffWhite,
                borderRadius: BorderRadius.all(Radius.circular(20.r))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  ReusableText(
                      text: "Đặt hàng thành công",
                      style: appStyle(14, kGray, FontWeight.w600)),
                  const Divider(thickness: .2, color: kGray),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                          text: "Phương thức",
                          style: appStyle(12, kGray, FontWeight.normal)),
                      ReusableText(
                          text: "Thanh toán khi nhận hàng (COD)",
                          style: appStyle(12, kGray, FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                          text: "Sản phẩm",
                          style: appStyle(12, kGray, FontWeight.normal)),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ReusableText(
                              text: orderController.codProductTitle,
                              style:
                                  appStyle(12, kGray, FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                          text: "Số lượng",
                          style: appStyle(12, kGray, FontWeight.normal)),
                      ReusableText(
                          text: "${orderController.codQuantity}",
                          style: appStyle(12, kGray, FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                          text: "Tổng tiền",
                          style: appStyle(12, kGray, FontWeight.normal)),
                      ReusableText(
                          text: usdToVndText(orderController.codTotalPrice),
                          style: appStyle(12, kGray, FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                          text: "Địa chỉ giao hàng",
                          style: appStyle(12, kGray, FontWeight.normal)),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ReusableText(
                              text: orderController.codAddressLine,
                              style:
                                  appStyle(12, kGray, FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: () {
                        Get.offAll(() => MainScreen());
                      },
                      child: const Text('Về trang chủ'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}