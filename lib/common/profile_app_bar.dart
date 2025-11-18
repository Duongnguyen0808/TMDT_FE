import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:appliances_flutter/views/profile/settings_page.dart';

class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final isVi = languageService.isVietnamese();
    return AppBar(
      backgroundColor: kOffWhite,
      elevation: 0,
      title: ReusableText(
        text: 'profile'.tr,
        style: appStyle(16, kDark, FontWeight.w600),
      ),
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final next =
                    isVi ? LanguageService.english : LanguageService.vietnamese;
                await languageService.setLanguage(next);
                Get.updateLocale(Locale(next));
                Get.snackbar('Ngôn ngữ',
                    'Đã chuyển sang ${languageService.getLanguageDisplayName()}',
                    backgroundColor: kPrimary,
                    colorText: kLightWhite,
                    duration: const Duration(seconds: 2));
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    isVi ? 'assets/icons/vn.svg' : 'assets/icons/en.svg',
                    width: 22.h,
                    height: 22.h,
                  ),
                  SizedBox(width: 6.w),
                  ReusableText(
                    text: isVi ? 'Tiếng Việt' : 'English',
                    style: appStyle(12, kDark, FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            GestureDetector(
              onTap: () {
                Get.to(() => const SettingsPage(),
                    transition: Transition.cupertino,
                    duration: const Duration(milliseconds: 400));
              },
              child: Padding(
                padding: EdgeInsets.only(right: 12.w, bottom: 4.h),
                child: Icon(SimpleLineIcons.settings, size: 20.h, color: kDark),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
