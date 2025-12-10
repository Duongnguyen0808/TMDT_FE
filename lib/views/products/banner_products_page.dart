import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/banner_model.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:appliances_flutter/widgets/dynamic_translated_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BannerProductsPage extends StatelessWidget {
  const BannerProductsPage({super.key, required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final products = banner.linkedProducts;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: ReusableText(
          text: banner.title,
          style: appStyle(18, kLightWhite, FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          autoTranslate: true,
        ),
      ),
      body: BackGroundContainer(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.only(bottom: 32.h),
          children: [
            _BannerHero(banner: banner),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                    text: 'banner_featured_products'.tr,
                    style: appStyle(16, kDark, FontWeight.w700),
                  ),
                  SizedBox(height: 10.h),
                  if (products.isEmpty)
                    _EmptyBannerProducts(bannerTitle: banner.title)
                  else
                    ...products
                        .map(
                          (product) => _BannerProductTile(
                            product: product,
                            formatter: formatter,
                          ),
                        )
                        .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerHero extends StatelessWidget {
  const _BannerHero({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final scheduleText = _buildScheduleText(banner);
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: kGrayLight),
                errorWidget: (_, __, ___) => Container(
                  color: kGrayLight,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: kGray,
                    size: 48.sp,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
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
                  DynamicTranslatedText(
                    banner.title,
                    style: TextStyle(
                      color: kLightWhite,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((banner.subtitle ?? '').isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: DynamicTranslatedText(
                        banner.subtitle!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if ((banner.description ?? '').isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: DynamicTranslatedText(
                        banner.description!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      if ((banner.ctaText ?? '').isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: kSecondary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: DynamicTranslatedText(
                            banner.ctaText!,
                            style: appStyle(12, kDark, FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (scheduleText != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14.sp,
                                color: kLightWhite,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                scheduleText,
                                style:
                                    appStyle(11, kLightWhite, FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildScheduleText(BannerModel banner) {
    if (banner.startAt == null && banner.endAt == null) return null;
    final start = banner.startAt;
    final end = banner.endAt;
    final isEnglish = LanguageService().isEnglish();
    final dateFormatter = DateFormat(isEnglish ? 'MM/dd' : 'dd/MM');
    if (start != null && end != null) {
      return '${dateFormatter.format(start)} → ${dateFormatter.format(end)}';
    }
    if (start != null) {
      return 'banner_schedule_from'
          .trParams({'date': dateFormatter.format(start)});
    }
    if (end != null) {
      return 'banner_schedule_until'
          .trParams({'date': dateFormatter.format(end)});
    }
    return null;
  }
}

class _BannerProductTile extends StatelessWidget {
  const _BannerProductTile({required this.product, required this.formatter});

  final BannerProduct product;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final isEnglish = languageService.isEnglish();
    final title =
        product.title.isEmpty ? 'banner_product_generic'.tr : product.title;
    final shouldTranslate = product.title.isNotEmpty;
    final stockText = product.stock != null
        ? (isEnglish
            ? 'In stock: ${product.stock}'
            : 'Kho còn: ${product.stock}')
        : (isEnglish ? 'Inventory is being updated' : 'Đang cập nhật tồn kho');
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: kGrayLight.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl.isEmpty
                  ? 'https://via.placeholder.com/120x120?text=Food'
                  : product.imageUrl,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: kGrayLight),
              errorWidget: (_, __, ___) => Container(
                color: kGrayLight,
                child: Icon(
                  Icons.image_outlined,
                  color: kGray,
                  size: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: title,
                  style: appStyle(15, kDark, FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  autoTranslate: shouldTranslate,
                ),
                SizedBox(height: 6.h),
                ReusableText(
                  text: stockText,
                  style: appStyle(12, kGray, FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  autoTranslate: true,
                ),
              ],
            ),
          ),
          Text(
            formatter.format(product.price),
            style: appStyle(15, kSecondary, FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyBannerProducts extends StatelessWidget {
  const _EmptyBannerProducts({required this.bannerTitle});

  final String bannerTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kGrayLight.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48.sp,
            color: kGray,
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'banner_empty_products'.trParams({'title': bannerTitle}),
              style: appStyle(13, kGray, FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
