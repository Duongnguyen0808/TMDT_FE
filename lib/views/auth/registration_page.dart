import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/registration_controller.dart';
import 'package:appliances_flutter/models/registration_model.dart';
import 'package:appliances_flutter/views/auth/widget/email_textfield.dart';
import 'package:appliances_flutter/views/auth/widget/password_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _userController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationController());
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        title: Center(
          child: ReusableText(
              text: "Đồ Gia Dụng Gia Đình",
              style: appStyle(20, kLightWhite, FontWeight.bold)),
        ),
      ),
      body: BackGroundContainer(
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 30.h,
              ),
              Lottie.asset("assets/anime/delivery.json"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        EmailTextField(
                          hintText: "Tên đăng nhập",
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(
                            CupertinoIcons.profile_circled,
                            size: 22,
                            color: kGrayLight,
                          ),
                          controller: _userController,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return "Vui lòng nhập tên đăng nhập";
                            if (v.length < 3)
                              return "Tên đăng nhập tối thiểu 3 ký tự";
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        EmailTextField(
                          hintText: "Email",
                          isEmail: true,
                          prefixIcon: const Icon(
                            CupertinoIcons.mail,
                            size: 22,
                            color: kGrayLight,
                          ),
                          controller: _emailController,
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        PasswordTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Obx(() => CustomButton(
                              text: "Đăng ký",
                              onTap: controller.isLoading
                                  ? null
                                  : () {
                                      final isValid =
                                          _formKey.currentState?.validate() ??
                                              false;
                                      if (!isValid) return;

                                      final model = RegistrationModel(
                                          username: _userController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text);

                                      final data =
                                          registrationModelToJson(model);
                                      controller.registrationFunction(data);
                                    },
                              btnHeight: 35.h,
                              btnWidth: width,
                              btnColor: controller.isLoading
                                  ? kGray.withOpacity(.6)
                                  : kPrimary,
                            )),
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
