// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/favorites_controller.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/views/appliances/appliances_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Future<void> _openDetail(BuildContext context, String id) async {
    // Hiển thị loading nhẹ khi tải chi tiết
    Get.dialog(
      Center(child: CircularProgressIndicator(color: kPrimary)),
      barrierDismissible: false,
    );
    try {
      final url = Uri.parse('$appBaseUrl/api/appliances/$id');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final appliances = AppliancesModel.fromJson(map);
        Get.back();
        Get.to(() => AppliancesPage(appliances: appliances),
            transition: Transition.cupertino,
            duration: const Duration(milliseconds: 900));
      } else {
        Get.back();
        Get.snackbar('Lỗi', 'Không thể tải chi tiết sản phẩm',
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error_outline));
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể tải chi tiết sản phẩm',
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error_outline));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favController = Get.put(FavoritesController());
    final favorites = favController.getFavorites();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kLightWhite,
          ),
        ),
        title: ReusableText(
          text: 'Sản phẩm yêu thích',
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
      ),
      body: BackGroundContainer(
        color: Colors.white,
        child: favorites.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Text('Danh sách yêu thích trống',
                      style: appStyle(12, kGray, FontWeight.w500)),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(12.h),
                child: ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, i) {
                    final fav = favorites[i];
                    final String id = (fav['id'] ?? '').toString();
                    final String title = (fav['title'] ?? '').toString();
                    final String image = (fav['image'] ?? '').toString();
                    final double price =
                        double.tryParse((fav['price'] ?? '0').toString()) ?? 0;
                    final double rating =
                        double.tryParse((fav['rating'] ?? '0').toString()) ?? 0;
                    final String time = (fav['time'] ?? '').toString();

                    return GestureDetector(
                      onTap: () => _openDetail(context, id),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(8.h),
                        height: 80.h,
                        width: width,
                        decoration: BoxDecoration(
                          color: kOffWhite,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: SizedBox(
                                width: 70.w,
                                height: 64.h,
                                child: image.isNotEmpty
                                    ? Image.network(image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, __) => Icon(
                                            Ionicons.image_outline,
                                            color: kGray))
                                    : Icon(Ionicons.image_outline,
                                        color: kGray),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ReusableText(
                                    text: title,
                                    style: appStyle(13, kDark, FontWeight.w600),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Ionicons.time_outline,
                                          size: 14.h, color: kGrayLight),
                                      SizedBox(width: 4.w),
                                      Text(time,
                                          style: appStyle(
                                              11, kGray, FontWeight.w400)),
                                      SizedBox(width: 10.w),
                                      Icon(Ionicons.star,
                                          size: 14.h, color: kSecondary),
                                      SizedBox(width: 4.w),
                                      Text(rating.toStringAsFixed(1),
                                          style: appStyle(
                                              11, kGray, FontWeight.w400)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              usdToVndText(price),
                              style: appStyle(12, kDark, FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
