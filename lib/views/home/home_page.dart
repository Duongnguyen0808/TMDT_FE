// ignore_for_file: prefer_const_constructors

import 'package:appliances_flutter/common/custom_container.dart';
import 'package:appliances_flutter/common/custom_appbar.dart';
import 'package:appliances_flutter/common/heading.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/category_controller.dart';
import 'package:appliances_flutter/views/home/featured_products_page.dart';
import 'package:appliances_flutter/views/home/for_you_page.dart';
import 'package:appliances_flutter/views/home/today_suggestions_page.dart';
import 'package:appliances_flutter/views/home/widgets/appliances_list.dart';
import 'package:appliances_flutter/views/home/widgets/category_appliances_list.dart';
import 'package:appliances_flutter/views/home/widgets/category_list.dart';
import 'package:appliances_flutter/views/home/widgets/featured_products_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.h),
        child: CustomAppBar(),
      ),
      body: SafeArea(
        child: CustomContainer(
          containerContent: Column(
            children: [
              const CategoryList(),
              Obx(
                () => controller.categoryValue == ''
                    ? Column(
                        children: [
                          Heading(
                            text: "Gợi ý hôm nay",
                            onTap: () {
                              Get.to(() => TodaySuggestionsPage(),
                                  transition: Transition.cupertino,
                                  duration: const Duration(milliseconds: 900));
                            },
                          ),
                          AppliancesList(),
                          Heading(
                            text: "Sản phẩm nổi bật",
                            onTap: () {
                              Get.to(() => FeaturedProductsPage(),
                                  transition: Transition.cupertino,
                                  duration: const Duration(milliseconds: 900));
                            },
                          ),
                          FeaturedProductsList(),
                          Heading(
                            text: "Dành cho bạn",
                            onTap: () {
                              Get.to(() => ForYouPage(),
                                  transition: Transition.cupertino,
                                  duration: const Duration(milliseconds: 900));
                            },
                          ),
                          AppliancesList(),
                        ],
                      )
                    : CustomContainer(
                        containerContent: Column(
                          children: [
                            Heading(
                              more: true,
                              text: "Explore ${controller.titleValue}Category",
                              onTap: () {
                                Get.to(() => TodaySuggestionsPage(),
                                    transition: Transition.cupertino,
                                    duration:
                                        const Duration(milliseconds: 900));
                              },
                            ),
                            const CategoryAppliancesList(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
