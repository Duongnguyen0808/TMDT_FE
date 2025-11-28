// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class RatingPage extends StatefulWidget {
  const RatingPage({
    super.key,
    required this.productId,
    required this.ratingType,
  });

  final String productId;
  final String ratingType; // 'Appliances' hoặc 'Store'

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isCheckingPurchase = true;
  bool _hasPurchased = false;

  String get _targetTitleText {
    switch (widget.ratingType) {
      case 'Driver':
        return 'Đánh giá tài xế';
      case 'Appliances':
        return 'Đánh giá sản phẩm';
      default:
        return 'Đánh giá cửa hàng';
    }
  }

  String get _targetLabelText {
    switch (widget.ratingType) {
      case 'Driver':
        return 'tài xế';
      case 'Appliances':
        return 'sản phẩm';
      default:
        return 'cửa hàng';
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfUserPurchased();
  }

  Future<void> _checkIfUserPurchased() async {
    try {
      final box = GetStorage();
      final String? token = box.read('token');
      final String? userId = box.read('userId');

      if (token == null || userId == null) {
        setState(() {
          _isCheckingPurchase = false;
          _hasPurchased = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            '$appBaseUrl/api/rating/check-purchased/${widget.ratingType}/${widget.productId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _hasPurchased = data['status'] == true;
          _isCheckingPurchase = false;
        });
      } else {
        setState(() {
          _hasPurchased = false;
          _isCheckingPurchase = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasPurchased = false;
        _isCheckingPurchase = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPurchase) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_targetTitleText,
              style: appStyle(18, kLightWhite, FontWeight.w600)),
          backgroundColor: kPrimary,
          foregroundColor: kLightWhite,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPurchased) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_targetTitleText,
              style: appStyle(18, kLightWhite, FontWeight.w600)),
          backgroundColor: kPrimary,
          foregroundColor: kLightWhite,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: kLightWhite),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 100.h,
                  color: kGray,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Chưa thể đánh giá',
                  style: appStyle(20, kDark, FontWeight.w600),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Bạn cần hoàn tất giao dịch với ${_targetLabelText} này trước khi đánh giá',
                  textAlign: TextAlign.center,
                  style: appStyle(14, kGray, FontWeight.normal),
                ),
                SizedBox(height: 30.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Quay lại',
                    style: appStyle(14, kLightWhite, FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_targetTitleText,
            style: appStyle(18, kLightWhite, FontWeight.w600)),
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kLightWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn cảm thấy thế nào về ${_targetLabelText} này?',
                style: appStyle(16, kDark, FontWeight.w600)),
            SizedBox(height: 20.h),
            Center(
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            SizedBox(height: 20.h),
            Text('Chia sẻ thêm về trải nghiệm với ${_targetLabelText}:',
                style: appStyle(14, kDark, FontWeight.w500)),
            SizedBox(height: 10.h),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Viết nhận xét của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: kPrimary),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () async {
                  if (_rating == 0) {
                    Get.snackbar(
                      'Vui lòng chọn số sao',
                      'Bạn chưa chọn số sao đánh giá',
                      backgroundColor: kRed,
                      colorText: kLightWhite,
                    );
                    return;
                  }

                  try {
                    final box = GetStorage();
                    final String? token = box.read('token');
                    final String? userId = box.read('userId');

                    if (token == null || userId == null) {
                      Get.snackbar(
                        'Chưa đăng nhập',
                        'Vui lòng đăng nhập để đánh giá',
                        backgroundColor: kRed,
                        colorText: kLightWhite,
                      );
                      return;
                    }

                    final response = await http.post(
                      Uri.parse('$appBaseUrl/api/rating'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode({
                        'ratingType': widget.ratingType,
                        'product': widget.productId,
                        'rating': _rating.toInt(),
                        'id': userId,
                        'comment': _commentController.text.trim(),
                      }),
                    );

                    if (response.statusCode == 200) {
                      Get.back(result: true); // Trả kết quả để refresh
                      Get.snackbar(
                        'Cảm ơn!',
                        'Đánh giá của bạn đã được gửi thành công',
                        backgroundColor: kPrimary,
                        colorText: kLightWhite,
                      );
                    } else {
                      final data = jsonDecode(response.body);
                      Get.snackbar(
                        'Lỗi',
                        data['message'] ?? 'Đánh giá thất bại',
                        backgroundColor: kRed,
                        colorText: kLightWhite,
                      );
                    }
                  } catch (e) {
                    Get.snackbar(
                      'Lỗi',
                      'Không thể gửi đánh giá: $e',
                      backgroundColor: kRed,
                      colorText: kLightWhite,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Gửi đánh giá',
                    style: appStyle(16, kLightWhite, FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
