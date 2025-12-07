import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetchBanners.dart';
import 'package:appliances_flutter/models/banner_model.dart';
import 'package:appliances_flutter/views/products/all_products_page.dart';
import 'package:appliances_flutter/views/products/banner_products_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class BannerWidget extends HookWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hook = useFetchBanners();
    final List<BannerModel>? banners = hook.data;

    if (hook.isLoading) {
      return const _BannerSkeleton();
    }

    if (hook.error != null) {
      return _BannerPlaceholder(
        message: hook.error!.toString(),
        onRetry: hook.refetch,
      );
    }

    if (banners == null || banners.isEmpty) {
      return _BannerPlaceholder(
        message: 'Banner đang được cập nhật, bạn quay lại sau nhé!',
        onRetry: hook.refetch,
      );
    }

    return CarouselSlider.builder(
      itemCount: banners.length,
      options: CarouselOptions(
        height: 180.h,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 0.92,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      itemBuilder: (context, index, realIndex) {
        final banner = banners[index];
        return _BannerCard(
          banner: banner,
          onTap: () => _handleBannerTap(banner),
        );
      },
    );
  }

  void _handleBannerTap(BannerModel banner) {
    if (banner.hasLinkedProducts) {
      Get.to(
        () => BannerProductsPage(banner: banner),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 450),
      );
      return;
    }

    final category = banner.category?.trim();
    String? resolvedCategory =
        (category != null && category.isNotEmpty) ? category : null;

    Get.to(
      () => AllProductsPage(
        category: resolvedCategory,
        title: banner.title,
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 450),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final BannerModel banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            decoration: BoxDecoration(
              color: kLightWhite,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: kGrayLight.withOpacity(0.2),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: kGrayLight,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: kGray,
                      size: 48.sp,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: 18.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: kLightWhite,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      if ((banner.subtitle ?? '').isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          banner.subtitle!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: kLightWhite,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if ((banner.ctaText ?? '').isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: kSecondary.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            banner.ctaText!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: kDark,
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: kGrayLight.withOpacity(0.4)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: kGray,
              size: 34.sp,
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kGray,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 10.h),
              TextButton(
                onPressed: onRetry,
                child: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              color: Colors.white,
            ),
          ),
        ),
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemCount: 2,
      ),
    );
  }
}
