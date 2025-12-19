import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_vouchers.dart';
import 'package:appliances_flutter/models/voucher.dart';
import 'package:appliances_flutter/services/api_client.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:appliances_flutter/widgets/dynamic_translated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VouchersPage extends HookWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hook = useFetchAvailableVouchers();
    final vouchers = hook.data ?? <Voucher>[];
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
          text: 'vouchers'.tr,
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'refresh'.tr,
            onPressed: hook.refetch,
            icon: const Icon(Icons.refresh, color: kLightWhite),
          ),
        ],
      ),
      body: BackGroundContainer(
        color: kOffWhite,
        child: hook.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vouchers.isEmpty
                ? const _Empty()
                : ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: vouchers.length,
                    itemBuilder: (_, i) => _VoucherCard(
                      voucher: vouchers[i],
                      onClaimed: hook.refetch,
                    ),
                  ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({required this.voucher, required this.onClaimed});
  final Voucher voucher;
  final VoidCallback? onClaimed;

  Future<void> _claim() async {
    final res = await ApiClient.instance
        .post('/api/voucher/claim', data: {'code': voucher.code});
    if (res.ok == true && res.data is Map<String, dynamic>) {
      Get.snackbar(
        'voucher_claim_success_title'.tr,
        'voucher_claim_success_message'.trParams({'code': voucher.code}),
        backgroundColor: kPrimary,
        colorText: kLightWhite,
      );
      onClaimed?.call();
    } else {
      Get.snackbar(
        'voucher_claim_fail_title'.tr,
        'voucher_claim_retry'.tr,
        backgroundColor: kRed,
        colorText: kLightWhite,
      );
    }
  }

  String _formatAmount(double value) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = LanguageService().getCurrentLanguage();
    final discountText = voucher.getDiscountText(locale: languageCode);
    final minOrderText = voucher.minOrderTotal > 0
        ? 'voucher_min_order'
            .trParams({'amount': _formatAmount(voucher.minOrderTotal)})
        : null;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kLightWhite,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: kGray.withOpacity(.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Ionicons.pricetag, size: 24.sp, color: kPrimary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DynamicTranslatedText(
                  voucher.title,
                  style: appStyle(15, kDark, FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(discountText, style: appStyle(12, kGray, FontWeight.w400)),
                if (minOrderText != null) ...[
                  SizedBox(height: 2.h),
                  Text(minOrderText,
                      style: appStyle(11, kGrayLight, FontWeight.w500)),
                ]
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _claim,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text('voucher_button_claim'.tr,
                style: appStyle(12, kLightWhite, FontWeight.w700)),
          ),
        ],
      ),
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
          Icon(Ionicons.pricetag_outline, size: 80.sp, color: kGrayLight),
          SizedBox(height: 12.h),
          ReusableText(
              text: 'voucher_empty_available'.tr,
              style: appStyle(16, kGray, FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('voucher_empty_hint'.tr,
              style: appStyle(12, kGray, FontWeight.w400)),
        ],
      ),
    );
  }
}
