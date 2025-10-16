import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/shimmers/categories_shimmer.dart';
import 'package:appliances_flutter/hooks/fetchCategories.dart';
import 'package:appliances_flutter/models/categories.dart';
import 'package:appliances_flutter/views/home/widgets/category_widget.dart';

class CategoryList extends HookWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchCategories();
    List<CategoriesModel>? categoriesList = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;

    return Container(
      height: 110.h,
      padding: EdgeInsets.only(left: 12.w, top: 10.h),
      child: isLoading
          ? const CatergoriesShimmer(itemCount: 8) // gọi shimmer 8 item
          : error != null
              ? Center(child: Text("Error: ${error.toString()}"))
              : categoriesList == null || categoriesList.isEmpty
                  ? const Center(child: Text("No categories found"))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoriesList.length,
                      itemBuilder: (context, i) {
                        CategoriesModel category = categoriesList[i];
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: CategoryWidget(category: category),
                        );
                      },
                    ),
    );
  }
}
