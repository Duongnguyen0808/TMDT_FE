import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  String? selectedCategory;
  RangeValues priceRange = const RangeValues(0, 1000000);
  double? selectedRating;
  String sortBy = 'default';

  final List<String> categories = [
    'all',
    'Bộ đồ nấu ăn',
    'Chảo và Nồi',
    'Dao và Thớt',
    'Dụng cụ nhà bếp',
    'Đồ nướng',
  ];

  final List<Map<String, dynamic>> sortOptions = [
    {'value': 'default', 'label': 'default'},
    {'value': 'price_asc', 'label': 'price_asc'},
    {'value': 'price_desc', 'label': 'price_desc'},
    {'value': 'rating', 'label': 'rating_high'},
    {'value': 'popular', 'label': 'popular'},
  ];

  @override
  void initState() {
    super.initState();
    // Load last filters if available
    final controller = Get.find<SearchAppliancesController>();
    if (controller.lastFilters != null) {
      selectedCategory = controller.lastFilters!['category'];
      if (controller.lastFilters!['minPrice'] != null) {
        priceRange = RangeValues(
          controller.lastFilters!['minPrice'].toDouble(),
          controller.lastFilters!['maxPrice']?.toDouble() ?? 1000000,
        );
      }
      selectedRating = controller.lastFilters!['minRating']?.toDouble();
      sortBy = controller.lastFilters!['sortBy'] ?? 'default';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        title: Text(
          'advanced_search'.tr,
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danh mục
            ReusableText(
              text: 'category'.tr,
              style: appStyle(16, kDark, FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return FilterChip(
                  label: Text(category == 'all' ? category.tr : category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: kPrimary,
                  labelStyle: TextStyle(
                    color: isSelected ? kLightWhite : kDark,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 24.h),

            // Khoảng giá
            ReusableText(
              text: 'price_range'.tr,
              style: appStyle(16, kDark, FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${priceRange.start.toInt().toString()}đ',
                  style: appStyle(14, kGray, FontWeight.w500),
                ),
                Text(
                  '${priceRange.end.toInt().toString()}đ',
                  style: appStyle(14, kGray, FontWeight.w500),
                ),
              ],
            ),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 1000000,
              divisions: 20,
              activeColor: kPrimary,
              labels: RangeLabels(
                '${priceRange.start.toInt()}đ',
                '${priceRange.end.toInt()}đ',
              ),
              onChanged: (values) {
                setState(() {
                  priceRange = values;
                });
              },
            ),

            SizedBox(height: 24.h),

            // Đánh giá
            ReusableText(
              text: 'min_rating'.tr,
              style: appStyle(16, kDark, FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              children: [1, 2, 3, 4, 5].map((rating) {
                final isSelected = selectedRating == rating.toDouble();
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16.h,
                        color: isSelected ? kLightWhite : Colors.amber,
                      ),
                      SizedBox(width: 4.w),
                      Text('$rating'),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedRating = selected ? rating.toDouble() : null;
                    });
                  },
                  selectedColor: kPrimary,
                  labelStyle: TextStyle(
                    color: isSelected ? kLightWhite : kDark,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 24.h),

            // Sắp xếp
            ReusableText(
              text: 'sort_by'.tr,
              style: appStyle(16, kDark, FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            ...sortOptions.map((option) {
              return RadioListTile<String>(
                title: Text(
                  option['label'].toString().tr,
                  style: appStyle(14, kDark, FontWeight.w500),
                ),
                value: option['value'],
                groupValue: sortBy,
                activeColor: kPrimary,
                onChanged: (value) {
                  setState(() {
                    sortBy = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),

            SizedBox(height: 32.h),

            // Nút áp dụng
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = null;
                        priceRange = const RangeValues(0, 1000000);
                        selectedRating = null;
                        sortBy = 'default';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'reset'.tr,
                      style: appStyle(14, kGray, FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      Get.back(result: {
                        'category': selectedCategory,
                        'minPrice': priceRange.start,
                        'maxPrice': priceRange.end,
                        'minRating': selectedRating,
                        'sortBy': sortBy,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: kLightWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'apply_filter'.tr,
                      style: appStyle(14, kLightWhite, FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
