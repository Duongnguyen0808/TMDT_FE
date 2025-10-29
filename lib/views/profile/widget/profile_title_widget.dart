import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ProfileTileWidget extends StatelessWidget {
  const ProfileTileWidget(
      {super.key, required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 0,
      onTap: onTap,
      leading: Icon(
        icon,
        size: 20,
      ),
      title: ReusableText(
          text: title, style: appStyle(11, kGray, FontWeight.normal)),
      trailing: title != "Cài đặt"
          ? const Icon(
              AntDesign.right,
              size: 16,
            )
          : SvgPicture.asset(
              'assets/icons/vn.svg',
              width: 15.w,
              height: 20.h,
            ),
    );
  }
}
