// Clean rebuild of MyReviewsPage after previous corruption.
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:appliances_flutter/services/api_client.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_my_ratings.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/appliances/appliances_page.dart';
import 'package:appliances_flutter/views/store/store_page.dart';

class MyReviewsPage extends HookWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hook = useFetchMyRatings();
    final ratings = hook.data ?? [];
    final isLoading = hook.isLoading;
    final languageService = LanguageService();
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
        title: ReusableText(
          text: 'Đánh giá của tôi',
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Đổi ngôn ngữ',
            onPressed: () async {
              final next = languageService.isVietnamese()
                  ? LanguageService.english
                  : LanguageService.vietnamese;
              await languageService.setLanguage(next);
              Get.updateLocale(Locale(next));
              Get.snackbar('Ngôn ngữ',
                  'Đã chuyển sang ${languageService.getLanguageDisplayName()}',
                  colorText: kLightWhite, backgroundColor: kPrimary);
            },
            icon: const Icon(Ionicons.language_outline, color: kLightWhite),
          ),
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
            : ratings.isEmpty
                ? _EmptyState(onRefresh: hook.refetch ?? () {})
                : ListView.separated(
                    padding: EdgeInsets.all(12.w),
                    itemBuilder: (context, i) => _RatingTile(item: ratings[i]),
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemCount: ratings.length,
                  ),
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.item});
  final UserRatingItem item;

  IconData _icon() {
    switch (item.ratingType) {
      case 'Store':
        return Icons.store;
      case 'Appliances':
        return Ionicons.cube_outline;
      case 'Driver':
        return Ionicons.car_outline;
      default:
        return Ionicons.help_circle_outline;
    }
  }

  Color _color() {
    switch (item.ratingType) {
      case 'Store':
        return kSecondary;
      case 'Appliances':
        return kPrimary;
      case 'Driver':
        return Colors.indigo;
      default:
        return kGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openEntity(context),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: kLightWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _color().withOpacity(.2)),
          boxShadow: [
            BoxShadow(
              color: _color().withOpacity(.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _color().withOpacity(.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(_icon(), color: _color()),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_displayTitle(),
                      style: appStyle(13, kDark, FontWeight.w600)),
                  SizedBox(height: 4.h),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < item.rating.round();
                      return Icon(filled ? Icons.star : Icons.star_border,
                          size: 16.sp,
                          color: filled ? Colors.amber : kGrayLight);
                    }),
                  ),
                  if (item.comment.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(item.comment,
                        style: appStyle(12, kGray, FontWeight.normal),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                  ],
                  SizedBox(height: 6.h),
                  Text(_timeAgo(item.createdAt),
                      style: appStyle(11, kGrayLight, FontWeight.w400)),
                  SizedBox(height: 4.h),
                  if (item.entity == null)
                    Text('Mã: ${item.product}',
                        style: appStyle(11, kGray, FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayTitle() {
    // Prefer enriched entity title if available
    final entity = item.entity;
    if (entity != null) {
      final title = entity['title'];
      if (title is String && title.trim().isNotEmpty) return title;
    }
    // Fallback to rating type
    return item.ratingType;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _openEntity(BuildContext context) async {
    Get.snackbar('Đang mở', 'Đang tải chi tiết...',
        colorText: kLightWhite, backgroundColor: kPrimary.withOpacity(.9));
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    try {
      if (item.ratingType == 'Appliances') {
        final res = await ApiClient.instance
            .get('/api/appliances/${item.product}', useCache: false);
        Get.back();
        if (res.ok && res.data is Map<String, dynamic>) {
          final appliances =
              AppliancesModel.fromJson(res.data as Map<String, dynamic>);
          Get.to(() => AppliancesPage(appliances: appliances),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 400));
        } else {
          _err(extra: 'Mã lỗi: ${res.statusCode}');
        }
      } else if (item.ratingType == 'Store') {
        final res = await ApiClient.instance
            .get('/api/stores/${item.product}', useCache: false);
        Get.back();
        if (res.ok && res.data is Map<String, dynamic>) {
          final store = StoreModel.fromJson(res.data as Map<String, dynamic>);
          Get.to(() => StorePage(store: store),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 400));
        } else {
          _err(extra: 'Mã lỗi: ${res.statusCode}');
        }
      } else if (item.ratingType == 'Driver') {
        Get.back();
        Get.snackbar('Chưa hỗ trợ', 'Chưa có trang chi tiết tài xế',
            colorText: kLightWhite, backgroundColor: kPrimary);
      } else {
        Get.back();
        _err(extra: 'Loại: ${item.ratingType}');
      }
    } catch (e) {
      Get.back();
      _err(extra: e.toString());
    }
  }

  void _err({String? extra}) {
    Get.snackbar(
        'Lỗi', 'Không thể mở chi tiết${extra != null ? '\n$extra' : ''}',
        colorText: kLightWhite, backgroundColor: kRed);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Ionicons.chatbubble_ellipses_outline,
              size: 90.sp, color: kGrayLight),
          SizedBox(height: 16.h),
          ReusableText(
              text: 'Bạn chưa có đánh giá nào',
              style: appStyle(16, kGray, FontWeight.w500)),
          SizedBox(height: 8.h),
          Text('Hãy mua hàng và đánh giá để xuất hiện tại đây',
              style: appStyle(13, kGray, FontWeight.normal),
              textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại')),
        ],
      ),
    );
  }
}
