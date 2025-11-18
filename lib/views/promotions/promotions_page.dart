import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_promotions.dart';
import 'package:appliances_flutter/models/promotion_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

class PromotionsPage extends HookWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hook = useFetchPromotions();
    final list = hook.data ?? [];
    final isLoading = hook.isLoading;
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
        title: ReusableText(
          text: 'Khuyến mãi',
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: hook.refetch,
            icon: const Icon(Icons.refresh, color: kLightWhite),
          ),
        ],
      ),
      body: BackGroundContainer(
        color: kOffWhite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : list.isEmpty
                ? const _Empty()
                : ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _PromotionCard(promo: list[i]),
                  ),
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promo});
  final PromotionModel promo;

  Color _statusColor() {
    switch (promo.status) {
      case 'sent':
        return kPrimary;
      case 'scheduled':
        return Colors.orange;
      case 'sending':
        return Colors.indigo;
      case 'cancelled':
        return kRed;
      default:
        return kGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final discount = promo.data['discount'];
    final banner = promo.imageUrl;
    return GestureDetector(
      onTap: () => _openPromo(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: kLightWhite,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _statusColor().withOpacity(.25)),
          boxShadow: [
            BoxShadow(
              color: _statusColor().withOpacity(.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (banner != null && banner.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: CachedNetworkImage(
                  imageUrl: banner,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          promo.title,
                          style: appStyle(15, kDark, FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _statusColor().withOpacity(.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          promo.status,
                          style: appStyle(10, _statusColor(), FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    promo.body,
                    style: appStyle(12, kGray, FontWeight.w400),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      if (discount != null)
                        _Chip(label: 'Giảm $discount%', color: kSecondary),
                      if (promo.variant != null)
                        _Chip(
                            label: 'Variant ${promo.variant}',
                            color: Colors.teal),
                      _Chip(
                          label: 'Từ ${_fmt(promo.startsAt)}', color: kPrimary),
                      if (promo.endsAt != null)
                        _Chip(
                            label: 'Đến ${_fmt(promo.endsAt!)}',
                            color: Colors.deepPurple),
                      _Chip(
                          label: 'Hit ${promo.successCount}',
                          color: Colors.green),
                      _Chip(label: 'Miss ${promo.failureCount}', color: kRed),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Ionicons.pricetag_outline,
                          size: 16.sp, color: kGray),
                      SizedBox(width: 4.w),
                      Text(
                        promo.isActive ? 'Đang diễn ra' : _statusText(),
                        style: appStyle(11, kGray, FontWeight.w500),
                      ),
                      const Spacer(),
                      Icon(Ionicons.chevron_forward,
                          size: 16.sp, color: kGrayLight)
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  String _statusText() {
    switch (promo.status) {
      case 'scheduled':
        return 'Chưa bắt đầu';
      case 'sending':
        return 'Đang gửi';
      case 'cancelled':
        return 'Đã hủy';
      case 'sent':
        return promo.isActive ? 'Đang diễn ra' : 'Đã kết thúc';
      default:
        return promo.status;
    }
  }

  void _openPromo(BuildContext context) {
    if (promo.deepLink != null && promo.deepLink!.isNotEmpty) {
      Get.snackbar('Điều hướng', 'Mở liên kết ${promo.deepLink}',
          backgroundColor: kPrimary, colorText: kLightWhite);
      // TODO: parse deepLink and navigate accordingly
    } else {
      Get.snackbar('Chi tiết', promo.body,
          backgroundColor: kPrimary, colorText: kLightWhite);
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: appStyle(10, color, FontWeight.w600)),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.gift_outline, size: 80.sp, color: kGrayLight),
          SizedBox(height: 12.h),
          ReusableText(
              text: 'Chưa có khuyến mãi',
              style: appStyle(16, kGray, FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Hãy quay lại sau hoặc kéo để làm mới',
              style: appStyle(12, kGray, FontWeight.w400)),
        ],
      ),
    );
  }
}
