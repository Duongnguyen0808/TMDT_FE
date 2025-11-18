import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/chat_controller.dart';
import 'package:appliances_flutter/views/chat/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ctrl = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    ctrl.loadUserConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOffWhite,
        elevation: 0,
        title: Text('Hộp chat', style: appStyle(16, kDark, FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (ctrl.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.conversations.isEmpty) {
          return Center(
            child: ReusableText(
              text: 'Chưa có hội thoại',
              style: appStyle(14, kGray, FontWeight.w400),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(12.w),
          itemBuilder: (_, i) {
            final c = ctrl.conversations[i];
            final peer = c['peer'];
            final name =
                (peer != null ? (peer['username'] ?? peer['name']) : 'Đối tác');
            final last = c['lastMessage'] ?? '';
            return ListTile(
              title: Text(name.toString(),
                  style: appStyle(15, kDark, FontWeight.w600)),
              subtitle: Text(last.toString(),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.to(() => ChatDetailPage(
                    conversationId: c['id'].toString(),
                    title: name.toString()));
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: ctrl.conversations.length,
        );
      }),
    );
  }
}
