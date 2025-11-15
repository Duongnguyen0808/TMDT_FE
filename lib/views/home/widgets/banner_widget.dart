import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/views/products/all_products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> banners = [
      {
        'image': 'assets/banner/banner.jpg',
        'title': 'Quà tặng đặc biệt',
        'subtitle': 'Giảm giá cho đơn hàng đầu tiên',
        'category': null,
      },
      {
        'image': 'assets/banner/banner2.jpg',
        'title': 'Bộ sưu tập đồ bếp',
        'subtitle': 'Chảo, nồi, dao cao cấp',
        'category': 'Bộ đồ nấu ăn',
      },
      {
        'image': 'assets/banner/banner3.jpg',
        'title': 'Giảm giá dưới 200K',
        'subtitle': 'Nhiều sản phẩm hấp dẫn',
        'category': null,
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180.h,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        viewportFraction: 0.92,
      ),
      items: banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Get.to(() => AllProductsPage(
                      category: banner['category'],
                      title: banner['title']!,
                    ));
              },
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: kLightWhite,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Banner image from assets
                        Image.asset(
                          banner['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: kGrayLight,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50.h,
                                  color: kGray,
                                ),
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        Positioned(
                          bottom: 20.h,
                          left: 20.w,
                          right: 20.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner['title']!,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: kLightWhite,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                banner['subtitle']!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: kLightWhite,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
