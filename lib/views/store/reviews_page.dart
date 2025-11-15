import 'dart:convert';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({
    super.key,
    required this.productId,
    required this.ratingType,
    required this.productName,
  });

  final String productId;
  final String ratingType;
  final String productName;

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<dynamic> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final url = Uri.parse(
          '$appBaseUrl/api/rating/${widget.ratingType}/${widget.productId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            reviews = data['ratings'] ?? [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        title: Text(
          'Đánh giá của ${widget.productName}',
          style: appStyle(16, kLightWhite, FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 80.w, color: kGray),
                      SizedBox(height: 16.h),
                      Text(
                        'Chưa có đánh giá nào',
                        style: appStyle(14, kGray, FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final userId = review['userId'];
                      final username = userId != null
                          ? userId['username'] ?? 'Ẩn danh'
                          : 'Ẩn danh';
                      final rating = (review['rating'] ?? 0).toDouble();
                      final comment = review['comment'] ?? '';
                      final createdAt = review['createdAt'];

                      String timeAgo = '';
                      if (createdAt != null) {
                        try {
                          final date = DateTime.parse(createdAt);
                          timeAgo = timeago.format(date, locale: 'vi');
                        } catch (e) {
                          timeAgo = '';
                        }
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: kPrimary,
                                    child: Text(
                                      username[0].toUpperCase(),
                                      style: appStyle(
                                          16, kLightWhite, FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ReusableText(
                                          text: username,
                                          style: appStyle(
                                              14, kDark, FontWeight.w600),
                                        ),
                                        if (timeAgo.isNotEmpty)
                                          Text(
                                            timeAgo,
                                            style: appStyle(
                                                11, kGray, FontWeight.w400),
                                          ),
                                      ],
                                    ),
                                  ),
                                  RatingBarIndicator(
                                    rating: rating,
                                    itemCount: 5,
                                    itemSize: 16.h,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              if (comment.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  comment,
                                  style: appStyle(13, kDark, FontWeight.w400),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
