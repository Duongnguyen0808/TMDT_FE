import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/store_model.dart';
import 'package:appliances_flutter/controllers/chat_controller.dart';
import 'package:appliances_flutter/views/chat/chat_detail_page.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appliances_flutter/views/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:get/get.dart';

class StoreTopBar extends StatelessWidget {
  const StoreTopBar({
    super.key,
    required this.store,
  });

  final StoreModel? store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Ionicons.chevron_back_circle,
              size: 28,
              color: kLightWhite,
            ),
          ),
          ReusableText(
              text: store!.title, style: appStyle(13, kDark, FontWeight.w600)),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final box = GetStorage();
                  final token = box.read('token');
                  if (token == null) {
                    Get.to(() => const LoginPage());
                    return;
                  }
                  final chat = Get.put(ChatController());
                  final convId = await chat.getOrCreateConversationWithVendor(
                      vendorId: store!.owner, storeId: store!.id);
                  if (convId != null) {
                    Get.to(() => ChatDetailPage(
                          conversationId: convId,
                          title: store!.title,
                        ));
                  }
                },
                child: const Icon(
                  Ionicons.chatbubble_ellipses,
                  size: 26,
                  color: kLightWhite,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
