import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';
import '../models/voucher.dart';
import 'package:intl/intl.dart';

class VoucherListSheet extends StatefulWidget {
  final double orderTotal;
  final String? storeId;
  final Function(Voucher?) onVoucherSelected;

  const VoucherListSheet({
    super.key,
    required this.orderTotal,
    this.storeId,
    required this.onVoucherSelected,
  });

  @override
  State<VoucherListSheet> createState() => _VoucherListSheetState();
}

class _VoucherListSheetState extends State<VoucherListSheet> {
  List<Voucher> vouchers = [];
  bool isLoading = true;
  String? error;
  Voucher? selectedVoucher;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      String url =
          '$appBaseUrl/api/voucher/available?orderTotal=${widget.orderTotal}';
      if (widget.storeId != null && widget.storeId!.isNotEmpty) {
        url += '&storeId=${widget.storeId}';
      }

      // Get token from storage
      final box = GetStorage();
      final token = box.read('token');

      debugPrint('[VoucherListSheet] Fetching from: $url');
      debugPrint(
          '[VoucherListSheet] Token: ${token != null ? "exists" : "missing"}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[VoucherListSheet] Status: ${response.statusCode}');
      debugPrint('[VoucherListSheet] Body: ${response.body}');

      // Check if response is JSON
      if (!response.body.startsWith('{') && !response.body.startsWith('[')) {
        setState(() {
          error = 'Server trả về HTML thay vì JSON. Kiểm tra backend.';
          isLoading = false;
        });
        return;
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final voucherResponse = VoucherResponse.fromJson(data);
        setState(() {
          vouchers = voucherResponse.data;
          isLoading = false;
        });
        debugPrint('[VoucherListSheet] Loaded ${vouchers.length} vouchers');
      } else {
        setState(() {
          error = data['message'] ?? 'Không thể tải danh sách voucher';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[VoucherListSheet] Error: $e');
      setState(() {
        error = 'Lỗi: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: kOffWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn Voucher',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: kWhite,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: kWhite),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64.sp, color: kGray),
                            SizedBox(height: 16.h),
                            Text(
                              error!,
                              style: TextStyle(color: kGray, fontSize: 14.sp),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _fetchVouchers,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : vouchers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.discount_outlined,
                                    size: 64.sp, color: kGray),
                                SizedBox(height: 16.h),
                                Text(
                                  'Không có voucher khả dụng',
                                  style:
                                      TextStyle(color: kGray, fontSize: 14.sp),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: vouchers.length,
                            itemBuilder: (context, index) {
                              final voucher = vouchers[index];
                              final discount =
                                  voucher.calculateDiscount(widget.orderTotal);
                              final isSelected =
                                  selectedVoucher?.id == voucher.id;

                              return Card(
                                margin: EdgeInsets.only(bottom: 12.h),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: isSelected ? kPrimary : kGrayLight,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12.r),
                                  onTap: () {
                                    setState(() {
                                      selectedVoucher = voucher;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Row(
                                      children: [
                                        // Voucher Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                voucher.title,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: kDark,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                voucher.code,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: kPrimary,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                voucher.getDiscountText(),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: kGray,
                                                ),
                                              ),
                                              if (voucher.minOrderTotal > 0)
                                                Text(
                                                  'Đơn tối thiểu: ${voucher.minOrderTotal.toInt()}đ',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: kGray,
                                                  ),
                                                ),
                                              if (voucher.validUntil != null)
                                                Text(
                                                  'HSD: ${_formatDate(voucher.validUntil)}',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: kGray,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // Discount Amount or Radio
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (discount > 0)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: kSecondary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Text(
                                                  '-${discount.toInt()}đ',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: kSecondary,
                                                  ),
                                                ),
                                              ),
                                            SizedBox(height: 8.h),
                                            Radio<String>(
                                              value: voucher.id,
                                              groupValue: selectedVoucher?.id,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedVoucher = voucher;
                                                });
                                              },
                                              activeColor: kPrimary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),

          // Bottom Buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kWhite,
              boxShadow: [
                BoxShadow(
                  color: kGray.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Clear Button
                if (selectedVoucher != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onVoucherSelected(null);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: kGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Bỏ chọn',
                        style: TextStyle(fontSize: 14.sp, color: kGray),
                      ),
                    ),
                  ),
                if (selectedVoucher != null) SizedBox(width: 12.w),

                // Apply Button
                Expanded(
                  flex: selectedVoucher != null ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: selectedVoucher != null
                        ? () {
                            widget.onVoucherSelected(selectedVoucher);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Áp dụng',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: kWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
