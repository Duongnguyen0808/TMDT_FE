import 'package:appliances_flutter/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final languageService = LanguageService();
  String currentLanguage = 'vi';

  @override
  void initState() {
    super.initState();
    currentLanguage = languageService.getCurrentLanguage();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('select_language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('🇻🇳 ${'vietnamese'.tr}'),
                value: LanguageService.vietnamese,
                groupValue: currentLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    _changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<String>(
                title: Text('🇬🇧 ${'english'.tr}'),
                value: LanguageService.english,
                groupValue: currentLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    _changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(String languageCode) async {
    await languageService.setLanguage(languageCode);

    // Update GetX locale
    Get.updateLocale(Locale(languageCode));

    setState(() {
      currentLanguage = languageCode;
    });

    // Show success message
    Get.snackbar(
      'success'.tr,
      '${'language_changed'.tr} ${languageService.getLanguageDisplayName()}',
      colorText: kWhite,
      backgroundColor: kPrimary,
      icon: const Icon(Icons.check_circle, color: kWhite),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOffWhite,
        elevation: 0,
        title: Text(
          'settings'.tr,
          style: TextStyle(
            color: kDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: kOffWhite,
        child: ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            // Language Section
            Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'general'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kGray,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: _showLanguageDialog,
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Ionicons.language_outline,
                        color: kPrimary,
                        size: 24.sp,
                      ),
                    ),
                    title: Text(
                      'language'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      languageService.getLanguageDisplayName(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: kGray,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: kGray,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // App Info Section
            Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'app_info'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kGray,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: kSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Ionicons.information_circle_outline,
                        color: kSecondary,
                        size: 24.sp,
                      ),
                    ),
                    title: Text(
                      'version'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "1.0.0",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: kGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Info Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kPrimary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Ionicons.information_circle,
                    color: kPrimary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'language_change_info'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: kDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
