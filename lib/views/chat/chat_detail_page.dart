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
  final ctrl = Get.find<ChatController>();
  final textCtrl = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOffWhite,
        elevation: 0,
        title: Text(widget.title, style: appStyle(16, kDark, FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: EdgeInsets.all(12.w),
                itemCount: ctrl.messages.length,
                itemBuilder: (_, i) {
                  final m = ctrl.messages[i];
                  final mine = m['senderType'] == 'Client';
                  final bottomInset = MediaQuery.of(context).padding.bottom;
                  return Scaffold(
                    backgroundColor: kPrimary,
                    appBar: AppBar(
                      backgroundColor: kPrimary,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: kLightWhite),
                        onPressed: () => Get.back(),
                      ),
                      title: Text(widget.chatStore.title),
                    ),
                    body: SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Obx(() {
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                CustomButton(
                  text: 'Gửi',
                  btnHeight: 40.h,
                    Container(
                      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, bottomInset + 8.h),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.chatController,
                              decoration: InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(Icons.send, color: kPrimary),
                            onPressed: controller.sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
