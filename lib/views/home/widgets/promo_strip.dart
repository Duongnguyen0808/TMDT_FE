import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/hooks/fetch_vouchers.dart';
import 'package:appliances_flutter/models/voucher.dart';
import 'package:appliances_flutter/views/vouchers/vouchers_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

/// A distinct promotional strip different from regular headings.
class PromoStrip extends HookWidget {
  const PromoStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final hook = useFetchAvailableVouchers();
    final List<Voucher> vouchers = hook.data ?? <Voucher>[];
    final int count = vouchers.length;
    return GestureDetector(
      onTap: () => Get.to(() => const VouchersPage(),
          transition: Transition.cupertino,
          duration: const Duration(milliseconds: 500)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8A00), Color(0xFFFF3D00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Ionicons.gift, color: kLightWhite, size: 26.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Săn voucher',
                      style: appStyle(16, kLightWhite, FontWeight.w700)),
                  SizedBox(height: 2.h),
                  Text(
                    count > 0
                        ? 'Có $count voucher có thể nhận • chạm để xem'
                        : (hook.isLoading
                            ? 'Đang tải voucher...'
                            : 'Nhận voucher để dùng khi thanh toán'),
                    style: appStyle(11, kLightWhite, FontWeight.w400),
                  ),
                ],
              ),
            ),
            Icon(Ionicons.chevron_forward, color: kLightWhite, size: 20.sp)
          ],
        ),
      ),
    );
  }
}
