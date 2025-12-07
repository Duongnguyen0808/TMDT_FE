import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  final String title;
  const ChatDetailPage(
      {super.key, required this.conversationId, required this.title});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatController ctrl = Get.find<ChatController>();
  final TextEditingController textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrl.loadMessages(widget.conversationId);
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = textCtrl.text.trim();
    if (content.isEmpty) return;

    FocusScope.of(context).unfocus();
    final success = await ctrl.sendMessage(widget.conversationId, content);
    if (success) {
      textCtrl.clear();
    } else {
      Get.snackbar('Tin nhắn', 'Không thể gửi tin nhắn',
          backgroundColor: kRed, colorText: kLightWhite);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOffWhite,
        elevation: 0,
        title: Text(widget.title, style: appStyle(16, kDark, FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDark),
          onPressed: Get.back,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (ctrl.messages.isEmpty) {
                return Center(
                  child: ReusableText(
                    text: 'Bắt đầu cuộc trò chuyện của bạn',
                    style: appStyle(14, kGray, FontWeight.w400),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(12.w),
                itemCount: ctrl.messages.length,
                itemBuilder: (context, index) {
                  final message = ctrl.messages[index];
                  final bool mine = message['senderType'] == 'Client';
                  final String content = message['content']?.toString() ?? '';

                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      constraints: BoxConstraints(maxWidth: 0.75.sw),
                      decoration: BoxDecoration(
                        color:
                            mine ? kPrimary.withValues(alpha: 0.15) : kOffWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                          bottomLeft: Radius.circular(mine ? 12.r : 4.r),
                          bottomRight: Radius.circular(mine ? 4.r : 12.r),
                        ),
                      ),
                      child: ReusableText(
                        text: content,
                        style: appStyle(14, kDark, FontWeight.w400),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: const BoxDecoration(color: kWhite),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide:
                                BorderSide(color: kGray.withValues(alpha: .3))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: const BorderSide(color: kPrimary)),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  CustomButton(
                    text: 'Gửi',
                    btnWidth: 70.w,
                    btnHeight: 40.h,
                    onTap: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
