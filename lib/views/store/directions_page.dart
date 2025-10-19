import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DirectionsPage extends StatelessWidget {
  const DirectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉ đường',
            style: appStyle(18, kLightWhite, FontWeight.w600)),
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Text('Trang chỉ đường',
            style: appStyle(16, kDark, FontWeight.w500)),
      ),
    );
  }
}
