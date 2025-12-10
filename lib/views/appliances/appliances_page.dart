// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:appliances_flutter/common/address_buttom_sheet.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/custom_text_field.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/appliances_controller.dart';
import 'package:appliances_flutter/controllers/cart_controller.dart';
import 'package:appliances_flutter/controllers/favorites_controller.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/hooks/fetch_default.dart';
import 'package:appliances_flutter/hooks/fetch_store.dart';
import 'package:appliances_flutter/models/address_response.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:appliances_flutter/models/cart_request.dart';
import 'package:appliances_flutter/models/login_response.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/views/auth/login_page.dart';
import 'package:appliances_flutter/views/auth/phone_verification_page.dart';
import 'package:appliances_flutter/models/order_model.dart' as order_model;
import 'package:appliances_flutter/views/orders/order_page.dart';
import 'package:appliances_flutter/views/store/rating_page.dart';
import 'package:appliances_flutter/views/store/reviews_page.dart';
import 'package:appliances_flutter/views/store/store_page.dart';
import 'package:appliances_flutter/controllers/chat_controller.dart';
import 'package:appliances_flutter/views/chat/chat_detail_page.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class AppliancesPage extends StatefulHookWidget {
  const AppliancesPage({super.key, required this.appliances});

  final AppliancesModel appliances;

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage>
    with WidgetsBindingObserver {
  final TextEditingController _preferences = TextEditingController();
  final PageController _pageController = PageController();
  late AppliancesController _appliancesController;
  bool _reviewsLoading = false;
  String? _reviewsError;
  List<dynamic> _recentReviews = [];
  Map<String, dynamic>? _reviewSummary;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    WidgetsBinding.instance.addObserver(this);
    // Khởi tạo controller và nạp additives một lần ở initState để tránh cập nhật reactive trong build
    _appliancesController = Get.put(AppliancesController());
    _appliancesController.loadAdditives(widget.appliances.additives);
    _loadReviewPreview();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refetch default address when app resumes
      setState(() {});
    }
  }

  Future<void> _loadReviewPreview() async {
    setState(() {
      _reviewsLoading = true;
      _reviewsError = null;
    });
    try {
      final url = Uri.parse(
          '$appBaseUrl/api/rating/Appliances/${widget.appliances.id}?limit=25');
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['status'] == true) {
          final List<dynamic> rawRatings = decoded['ratings'] is List
              ? List<dynamic>.from(decoded['ratings'] as List)
              : <dynamic>[];
          setState(() {
            _recentReviews =
                rawRatings.length > 3 ? rawRatings.sublist(0, 3) : rawRatings;
            _reviewSummary = decoded['summary'] is Map
                ? Map<String, dynamic>.from(
                    decoded['summary'] as Map,
                  )
                : null;
            _reviewsLoading = false;
          });
        } else {
          setState(() {
            _reviewsLoading = false;
            _reviewsError = decoded is Map && decoded['message'] != null
                ? decoded['message'].toString()
                : 'product_reviews_error'.tr;
          });
        }
      } else {
        setState(() {
          _reviewsLoading = false;
          _reviewsError = 'product_reviews_error_with_code'
              .trParams({'code': '${response.statusCode}'});
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reviewsLoading = false;
        _reviewsError = 'product_reviews_error'.tr;
      });
    }
  }

  List<Map<String, dynamic>> _recentReviewItems() {
    return _recentReviews
        .map<Map<String, dynamic>>((item) {
          if (item is Map<String, dynamic>) return item;
          if (item is Map) return Map<String, dynamic>.from(item);
          return <String, dynamic>{};
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  double _parseDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Map<int, int> _normalizedBreakdown(dynamic raw) {
    final map = {for (var i = 1; i <= 5; i++) i: 0};
    if (raw is Map) {
      raw.forEach((key, value) {
        final star = int.tryParse(key.toString());
        final count = value is int
            ? value
            : (value is num
                ? value.toInt()
                : int.tryParse(value.toString()) ?? 0);
        if (star != null && map.containsKey(star)) {
          map[star] = count;
        }
      });
    }
    return map;
  }

  String _formatReviewTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      final locale = _languageService.isEnglish() ? 'en' : 'vi';
      return timeago.format(date, locale: locale);
    } catch (_) {
      return '';
    }
  }

  Widget _buildReviewPreviewSection() {
    final summary = _reviewSummary;
    final average = summary != null
        ? _parseDouble(summary['average'], widget.appliances.rating)
        : widget.appliances.rating;
    final total = summary != null
        ? _parseInt(summary['total'], widget.appliances.ratingCount)
        : widget.appliances.ratingCount;
    final breakdown = _normalizedBreakdown(summary?['breakdown']);
    final reviews = _recentReviewItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ReusableText(
                text: 'product_reviews_title'.tr,
                style: appStyle(18, kDark, FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await Get.to(() => ReviewsPage(
                      productId: widget.appliances.id,
                      ratingType: 'Appliances',
                      productName: widget.appliances.title,
                    ));
                if (mounted) _loadReviewPreview();
              },
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: Text('product_reviews_view_all'.tr),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_reviewsLoading)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kOffWhite,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12.w),
                ReusableText(
                  text: 'product_reviews_loading'.tr,
                  style: appStyle(13, kGray, FontWeight.w500),
                ),
              ],
            ),
          )
        else if (_reviewsError != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kRed.withOpacity(.05),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: _reviewsError!,
                  style: appStyle(13, kRed, FontWeight.w500),
                  autoTranslate: true,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
                TextButton(
                  onPressed: _loadReviewPreview,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          )
        else if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kOffWhite,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: 'product_reviews_empty'.tr,
                  style: appStyle(13, kGray, FontWeight.w500),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () async {
                    final result = await Get.to(() => RatingPage(
                          productId: widget.appliances.id,
                          ratingType: 'Appliances',
                        ));
                    if (result == true && mounted) {
                      _loadReviewPreview();
                    }
                  },
                  child: Text('product_reviews_write_first'.tr),
                ),
              ],
            ),
          )
        else ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kOffWhite,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: kPrimary.withOpacity(.05)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: appStyle(28, kPrimary, FontWeight.w700),
                    ),
                    RatingBarIndicator(
                      rating: average.clamp(0, 5),
                      itemBuilder: (_, __) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 18.h,
                      unratedColor: kGrayLight.withOpacity(.3),
                    ),
                    SizedBox(height: 4.h),
                    ReusableText(
                      text:
                          'product_reviews_total'.trParams({'count': '$total'}),
                      style: appStyle(12, kGray, FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      final count = breakdown[star] ?? 0;
                      final ratio = total > 0 ? count / total : 0.0;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30.w,
                              child: Text(
                                '$star★',
                                style: appStyle(11, kGray, FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: kGrayLight.withOpacity(.2),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(kSecondary),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '$count',
                              style: appStyle(11, kDark, FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          ...reviews.map(_buildReviewCard).toList(),
        ],
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final user = review['userId'];
    final fallbackName = 'reviews_anonymous'.tr;
    final username = user is Map && user['username'] is String
        ? (user['username'] as String)
        : fallbackName;
    final ratingValue = review['rating'] is num
        ? (review['rating'] as num).toDouble()
        : double.tryParse(review['rating']?.toString() ?? '') ?? 0;
    final displayRating = ratingValue.clamp(0, 5);
    final comment = (review['comment'] ?? '').toString();
    final createdAt = review['createdAt']?.toString();
    final timeLabel = _formatReviewTime(createdAt);
    final avatarLabel = username.isNotEmpty
        ? username[0].toUpperCase()
        : fallbackName[0].toUpperCase();

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: kSecondary.withOpacity(.15),
                  child: Text(
                    avatarLabel,
                    style: appStyle(14, kSecondary, FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableText(
                        text: username,
                        style: appStyle(13, kDark, FontWeight.w600),
                      ),
                      if (timeLabel.isNotEmpty)
                        ReusableText(
                          text: timeLabel,
                          style: appStyle(11, kGray, FontWeight.w400),
                        ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: displayRating.toDouble(),
                  itemBuilder: (_, __) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 14.h,
                  unratedColor: kGrayLight.withOpacity(.3),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ReusableText(
                text: comment,
                style: appStyle(12, kDark, FontWeight.w400),
                autoTranslate: true,
                maxLines: 6,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final favController = Get.put(FavoritesController());
    final box = GetStorage();
    LoginResponse? user;
    // Chỉ lấy địa chỉ mặc định khi đã đăng nhập
    final String? token = box.read('token');
    final bool isLoggedIn = token != null && token.isNotEmpty;
    final defaultHook = isLoggedIn ? useFetchDefault(context) : null;
    AddressResponse? address = isLoggedIn ? defaultHook!.data : null;
    // Check xem có địa chỉ nào không (bất kể default hay không)
    final bool hasAddress = address != null;
    final hookResult = useFetchStoreById(widget.appliances.store);
    StoreModel? store = hookResult.data;
    final loginController = Get.put(LoginController());
    user = loginController.getUserInfo();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Show loading while fetching address (nếu có)
    if (isLoggedIn && defaultHook!.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kPrimary),
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(bottom: bottomInset + 24.h),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.r)),
            child: Stack(
              children: [
                SizedBox(
                  height: 230.h,
                  child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) {
                        _appliancesController.changePage(i);
                      },
                      itemCount: widget.appliances.imageUrl.length,
                      itemBuilder: (context, i) {
                        return Container(
                          width: width,
                          height: 230.h,
                          color: kLightWhite,
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget.appliances.imageUrl[i]),
                        );
                      }),
                ),
                Positioned(
                  bottom: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            widget.appliances.imageUrl.length, (index) {
                          return Container(
                            margin: EdgeInsets.all(4.h),
                            width: 10.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _appliancesController.currentPage == index
                                        ? kSecondary
                                        : kGrayLight),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Ionicons.chevron_back_circle,
                      color: kPrimary,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  top: 40.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () =>
                        favController.toggleFavorite(widget.appliances),
                    child: Obx(() {
                      final isFav =
                          favController.isFavorite(widget.appliances.id);
                      return CircleAvatar(
                        radius: 16.r,
                        backgroundColor: isFav ? kRed : kLightWhite,
                        child: Icon(
                          isFav ? Ionicons.heart : Ionicons.heart_outline,
                          color: isFav ? kLightWhite : kRed,
                          size: 18,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12.w,
                  child: Row(
                    children: [
                      CustomButton(
                        onTap: () async {
                          final box = GetStorage();
                          final token = box.read('token');
                          if (token == null) {
                            Get.to(() => const LoginPage());
                            return;
                          }
                          if (store == null) return;
                          final chat = Get.put(ChatController());
                          final convId =
                              await chat.getOrCreateConversationWithVendor(
                                  vendorId: store.owner, storeId: store.id);
                          if (convId != null) {
                            Get.to(() => ChatDetailPage(
                                  conversationId: convId,
                                  title: store.title,
                                ));
                          }
                        },
                        btnWidth: 120.w,
                        text: "Chat cửa hàng",
                      ),
                      SizedBox(width: 8.w),
                      CustomButton(
                        onTap: () {
                          Get.to(() => StorePage(
                                store: store,
                              ));
                        },
                        btnWidth: 120.w,
                        text: "Xem cửa hàng",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReusableText(
                              text: widget.appliances.title,
                              style: appStyle(18, kDark, FontWeight.w600)),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.star, color: kSecondary, size: 16.h),
                              SizedBox(width: 4.w),
                              ReusableText(
                                text:
                                    widget.appliances.rating.toStringAsFixed(1),
                                style: appStyle(14, kDark, FontWeight.w500),
                              ),
                              SizedBox(width: 8.w),
                              if (widget.appliances.stock != null) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: (widget.appliances.stock == 0
                                            ? kRed
                                            : kPrimary)
                                        .withOpacity(.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: ReusableText(
                                    text: widget.appliances.stock == 0
                                        ? 'Hết hàng'
                                        : 'Còn lại: ${widget.appliances.stock}',
                                    style: appStyle(
                                        11,
                                        widget.appliances.stock == 0
                                            ? kRed
                                            : kPrimary,
                                        FontWeight.w600),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                              ],
                              GestureDetector(
                                onTap: () async {
                                  final result = await Get.to(
                                    () => RatingPage(
                                      productId: widget.appliances.id,
                                      ratingType: 'Appliances',
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    // Refresh trang nếu đánh giá thành công
                                    setState(() {});
                                    _loadReviewPreview();
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: kSecondary,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: ReusableText(
                                    text: 'product_reviews_button'.tr,
                                    style: appStyle(
                                        11, kLightWhite, FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => ReusableText(
                          text: usdToVndText((widget.appliances.price +
                                  _appliancesController.additivePrice) *
                              _appliancesController.count.value),
                          style: appStyle(18, kPrimary, FontWeight.w600)),
                    )
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  widget.appliances.description,
                  textAlign: TextAlign.justify,
                  maxLines: 8,
                  style: appStyle(11, kGray, FontWeight.w400),
                ),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  height: 18.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                        widget.appliances.appliancesTags.length, (index) {
                      final tag = widget.appliances.appliancesTags[index];
                      return Container(
                        margin: EdgeInsets.only(right: 5.w),
                        decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.r))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: ReusableText(
                            text: tag,
                            style: appStyle(11, kWhite, FontWeight.w400),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                _buildReviewPreviewSection(),
                SizedBox(
                  height: 16.h,
                ),
                ReusableText(
                    text: "Tuỳ chọn thêm",
                    style: appStyle(18, kDark, FontWeight.w600)),
                SizedBox(
                  height: 10.h,
                ),
                Obx(
                  () => Column(
                    children: List.generate(
                        _appliancesController.additivesList.length, (index) {
                      final additive =
                          _appliancesController.additivesList[index];
                      return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          activeColor: kSecondary,
                          value: additive.isChecked.value,
                          tristate: false,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ReusableText(
                                  text: additive.title,
                                  style: appStyle(11, kDark, FontWeight.w400)),
                              SizedBox(
                                width: 5.w,
                              ),
                              ReusableText(
                                  text: usdToVndText(
                                      double.tryParse(additive.price) ?? 0.0),
                                  style:
                                      appStyle(11, kPrimary, FontWeight.w600)),
                            ],
                          ),
                          onChanged: (bool? value) {
                            additive.toggleChecked();
                            _appliancesController.getTotalPrice();
                            _appliancesController.getCartAdditive();
                          });
                    }),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableText(
                        text: "Số lượng",
                        style: appStyle(18, kDark, FontWeight.bold)),
                    SizedBox(
                      width: 5.w,
                    ),
                    Row(
                      children: [
                        Obx(() {
                          final int? stock = widget.appliances.stock;
                          final canIncrease = stock == null ||
                              _appliancesController.count.value < stock;
                          return GestureDetector(
                            onTap: canIncrease
                                ? () {
                                    _appliancesController.increment();
                                  }
                                : () {
                                    Get.snackbar('Giới hạn',
                                        'Đạt số lượng tối đa trong kho',
                                        backgroundColor: kPrimary,
                                        colorText: kLightWhite);
                                  },
                            child: Icon(
                              AntDesign.pluscircleo,
                              color: canIncrease ? kDark : kGrayLight,
                            ),
                          );
                        }),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Obx(
                              () => ReusableText(
                                  text: "${_appliancesController.count.value}",
                                  style: appStyle(14, kDark, FontWeight.w600)),
                            )),
                        Obx(() {
                          final canDecrease =
                              _appliancesController.count.value > 1;
                          return GestureDetector(
                            onTap: canDecrease
                                ? () {
                                    _appliancesController.decrement();
                                  }
                                : null,
                            child: Icon(
                              AntDesign.minuscircleo,
                              color: canDecrease ? kDark : kGrayLight,
                            ),
                          );
                        })
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                ReusableText(
                  text: "Ghi chú",
                  style: appStyle(18, kDark, FontWeight.w600),
                ),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  height: 65.h,
                  child: CustomTextField(
                    controller: _preferences,
                    hintText: "Thêm ghi chú cho món của bạn",
                    maxLines: 3,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(30.r)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final int? stock = widget.appliances.stock;
                          if (user == null) {
                            Get.to(() => const LoginPage());
                          } else if (user.phoneVerification == false) {
                            showVerificationSheet(context);
                          } else if (!hasAddress) {
                            showAddressSheet(context);
                          } else if (stock != null && stock == 0) {
                            Get.snackbar(
                                'Hết hàng', 'Sản phẩm này tạm thời hết hàng',
                                backgroundColor: kRed, colorText: kLightWhite);
                          } else if (stock != null &&
                              _appliancesController.count.value > stock) {
                            Get.snackbar('Lỗi', 'Số lượng vượt quá tồn kho',
                                backgroundColor: kRed, colorText: kLightWhite);
                          } else {
                            double price = (widget.appliances.price +
                                    _appliancesController.additivePrice) *
                                _appliancesController.count.value;

                            // Nếu store chưa tải xong, vẫn cho điều hướng.
                            // OrderPage đã xử lý khi store null và hiển thị fallback.

                            final order_model.OrderItem item =
                                order_model.OrderItem(
                                    appliancesId: order_model.AppliancesId(
                                      id: widget.appliances.id,
                                      title: widget.appliances.title,
                                      rating: widget.appliances.rating,
                                      imageUrl: widget.appliances.imageUrl,
                                      time: widget.appliances.time,
                                    ),
                                    quantity: _appliancesController.count.value,
                                    price: price,
                                    additives:
                                        _appliancesController.getCartAdditive(),
                                    instructions: _preferences.text,
                                    id: "" // placeholder id; backend assigns real id on order
                                    );

                            Get.to(
                              () => OrderPage(
                                item: item,
                                store: store,
                                appliances: widget.appliances,
                                address: address,
                              ),
                              transition: Transition.cupertino,
                              duration: const Duration(milliseconds: 900),
                            );
                          }
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: ReusableText(
                                text: "Đặt hàng",
                                style:
                                    appStyle(18, kLightWhite, FontWeight.w600)),
                          ),
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          final int? stock = widget.appliances.stock;
                          if (stock != null && stock == 0) {
                            Get.snackbar('Hết hàng', 'Không thể thêm vào giỏ',
                                backgroundColor: kRed, colorText: kLightWhite);
                            return;
                          }
                          if (stock != null &&
                              _appliancesController.count.value > stock) {
                            Get.snackbar(
                                'Giới hạn', 'Số lượng vượt quá tồn kho',
                                backgroundColor: kRed, colorText: kLightWhite);
                            return;
                          }
                          double price = (widget.appliances.price +
                                  _appliancesController.additivePrice) *
                              _appliancesController.count.value;

                          var data = CartRequest(
                              productId: widget.appliances.id,
                              additives:
                                  _appliancesController.getCartAdditive(),
                              quantity: _appliancesController.count.value,
                              totalPrice: price);

                          String cart = cartRequestToJson(data);

                          cartController.addToCart(cart);
                        },
                        child: CircleAvatar(
                          backgroundColor: kSecondary,
                          radius: 20.r,
                          child: const Icon(
                            Ionicons.cart,
                            color: kLightWhite,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ✅ Phiên bản mới: Không scroll, vừa khít nội dung
  Future<dynamic> showVerificationSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/restaurant_bk.png'),
              fit: BoxFit.fill,
            ),
            color: kLightWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 Fit đúng nội dung
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReusableText(
                text: "Xác thực số điện thoại",
                style: appStyle(18, kPrimary, FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              Column(
                children: List.generate(
                  verificationReasons.length,
                  (index) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading:
                          Icon(Icons.check_circle_outline, color: kPrimary),
                      title: Text(
                        verificationReasons[index],
                        textAlign: TextAlign.justify,
                        style: appStyle(12, kGray, FontWeight.normal),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              CustomButton(
                text: "Xác thực số điện thoại",
                btnHeight: 40.h,
                onTap: () {
                  Get.to(() => const PhoneVerificationPage());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
