import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Ảnh public, không bị 403/hotlink block
    const avatarUrl = 'https://picsum.photos/seed/user/200';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      height: 110.h,
      width: double.infinity, // Đừng ép width từ hằng số dễ sai
      color: kOffWhite,
      child: Container(
        margin: EdgeInsets.only(top: 20.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Cụm trái co giãn hợp lệ -> tránh overflow
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar + fallback, không throw exception khi lỗi ảnh
                  ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 44.r,
                      height: 44.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 44.r,
                        height: 44.r,
                        color: kSecondary,
                        alignment: Alignment.center,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 22.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Phần text đặt trong Expanded để nhận ràng buộc chiều ngang
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReusableText(
                            text: "Deliver to",
                            style: appStyle(13, kSecondary, FontWeight.w600),
                          ),
                          // Dùng Flexible thay vì SizedBox(width: double.infinity)
                          Flexible(
                            child: Text(
                              "16768 21st Ave N, Plymouth, MN 55447",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  appStyle(11, kGrayLight, FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cụm phải: icon thời gian (không giãn)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                getTimeOfDay(),
                style: const TextStyle(fontSize: 28), // 35 dễ tràn trên màn nhỏ
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeOfDay() {
    final h = DateTime.now().hour;
    if (h < 12) return ' ☀️ ';
    if (h < 16) return ' ⛅ ';
    return ' 🌙 ';
  }
}
