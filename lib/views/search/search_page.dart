// ignore_for_file: unused_field

import 'package:appliances_flutter/common/custom_container.dart';
import 'package:appliances_flutter/common/shimmers/foodlist_shimmer.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/search_controller.dart';
import 'package:appliances_flutter/views/search/advanced_search.dart';
import 'package:appliances_flutter/views/search/loading_widget.dart';
import 'package:appliances_flutter/views/search/search_result.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchAppliancesController());
    return Obx(() => Scaffold(
          backgroundColor: kLightWhite,
          appBar: AppBar(
            toolbarHeight: 64.h,
            elevation: 1,
            automaticallyImplyLeading: false,
            backgroundColor: kPrimary,
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: kLightWhite),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: kLightWhite,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "search_products".tr,
                        hintStyle: TextStyle(
                          color: kGray,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: kGray,
                          size: 22.h,
                        ),
                        suffixIcon: controller.isTriggered
                            ? IconButton(
                                icon:
                                    Icon(Icons.close, color: kGray, size: 20.h),
                                onPressed: () {
                                  controller.searchResults = null;
                                  controller.setTrigger = false;
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.sp),
                      onChanged: (value) {
                        _debounce?.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 300), () {
                          final key = value.trim();
                          if (key.length >= 2) {
                            if (!controller.isTriggered) {
                              controller.setTrigger = true;
                            }
                            controller.searchFoods(key);
                          } else {
                            controller.searchResults = null;
                            controller.setTrigger = false;
                          }
                        });
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.searchFoods(value.trim());
                          controller.setTrigger = true;
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Ionicons.options_outline,
                    color: kLightWhite, size: 24.h),
                onPressed: () async {
                  final filters =
                      await Get.to(() => const AdvancedSearchPage());
                  if (filters != null) {
                    controller.applyFilters(
                      _searchController.text,
                      filters,
                    );
                  }
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: SafeArea(
            child: CustomContainer(
                color: Colors.white,
                containerContent: controller.isLoading
                    ? const FoodsListShimmer()
                    : controller.searchResults == null
                        ? const LoadingWidget()
                        : const SearchResults()),
          ),
        ));
  }
}
