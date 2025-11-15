import 'dart:convert';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  List<Map<String, dynamic>> vouchers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final response = await http.get(
        Uri.parse('$appBaseUrl/api/voucher/all'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          vouchers = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching vouchers: $e');
    }
  }

  void _copyVoucherCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Đã sao chép',
      'Mã giảm giá "$code" đã được sao chép',
      backgroundColor: kPrimary,
      colorText: kLightWhite,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        elevation: 0,
        title: ReusableText(
          text: 'Phiếu giảm giá',
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: BackGroundContainer(
        color: kLightWhite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : vouchers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 100.h,
                          color: kGray,
                        ),
                        SizedBox(height: 16.h),
                        ReusableText(
                          text: 'Chưa có phiếu giảm giá',
                          style: appStyle(16, kGray, FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchVouchers,
                    child: ListView.builder(
                      padding: EdgeInsets.all(12.w),
                      itemCount: vouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = vouchers[index];
                        final discount = voucher['discount'] ?? 0;
                        final code = voucher['code'] ?? '';
                        final title = voucher['title'] ?? 'Phiếu giảm giá';

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kPrimary.withOpacity(0.8),
                                kSecondary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Stack(
                              children: [
                                // Decorative circles
                                Positioned(
                                  right: -20.w,
                                  top: -20.h,
                                  child: Container(
                                    width: 100.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kLightWhite.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -30.w,
                                  bottom: -30.h,
                                  child: Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kLightWhite.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      // Left side - Discount
                                      Container(
                                        width: 80.w,
                                        height: 80.h,
                                        decoration: BoxDecoration(
                                          color: kLightWhite,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${discount}đ',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: kPrimary,
                                              ),
                                            ),
                                            Text(
                                              'OFF',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: kSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      // Middle - Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: kLightWhite,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 8.h),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: kLightWhite
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                                border: Border.all(
                                                  color: kLightWhite
                                                      .withOpacity(0.3),
                                                  style: BorderStyle.solid,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                code,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: kLightWhite,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      // Right side - Copy button
                                      IconButton(
                                        onPressed: () => _copyVoucherCode(code),
                                        icon: Icon(
                                          Icons.copy,
                                          color: kLightWhite,
                                          size: 24.h,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
