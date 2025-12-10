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

class ProfileAppBar extends StatefulWidget {
  const ProfileAppBar({super.key});

  @override
  State<ProfileAppBar> createState() => _ProfileAppBarState();
}

class _ProfileAppBarState extends State<ProfileAppBar> {
  final LanguageService _languageService = LanguageService();
  late String _currentLanguage;

  bool get _isVietnamese => _currentLanguage == LanguageService.vietnamese;

  @override
  void initState() {
    super.initState();
    _currentLanguage = _languageService.getCurrentLanguage();
  }

  Future<void> _toggleLanguage() async {
    final next =
        _isVietnamese ? LanguageService.english : LanguageService.vietnamese;
    await _languageService.setLanguage(next);
    if (mounted) {
      setState(() {
        _currentLanguage = next;
      });
    }
    Get.snackbar(
      'language'.tr,
      '${'language_changed'.tr} ${_languageService.getLanguageDisplayName()}',
      backgroundColor: kPrimary,
      colorText: kLightWhite,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: _toggleLanguage,
              child: Row(
                children: [
                  SvgPicture.asset(
                    _isVietnamese
                        ? 'assets/icons/vn.svg'
                        : 'assets/icons/usa.svg',
                    width: 22.h,
                    height: 22.h,
                  ),
                  SizedBox(width: 6.w),
                  ReusableText(
                    text: _isVietnamese ? 'vietnamese'.tr : 'english'.tr,
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
