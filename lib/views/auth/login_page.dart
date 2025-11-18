import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/common/shimmers/custom_button.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/login_controller.dart';
import 'package:appliances_flutter/models/login_model.dart';
import 'package:appliances_flutter/views/auth/registration_page.dart';
import 'package:appliances_flutter/views/auth/forgot_password_page.dart';
import 'package:appliances_flutter/views/auth/widget/email_textfield.dart';
import 'package:appliances_flutter/views/auth/widget/password_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController = TextEditingController();
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
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        title: Center(
          child: ReusableText(
              text: "Đồ Gia Dụng",
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
                          hintText: "Email",
                          isEmail: true,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_passwordFocusNode),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Get.to(() => const RegistrationPage(),
                                        transition: Transition.fadeIn,
                                        duration:
                                            const Duration(milliseconds: 1200));
                                  },
                                  child: ReusableText(
                                      text: "Đăng ký",
                                      style: appStyle(
                                          12, Colors.blue, FontWeight.normal))),
                              GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => const ForgotPasswordPage(),
                                      transition: Transition.fadeIn,
                                      duration:
                                          const Duration(milliseconds: 600),
                                    );
                                  },
                                  child: ReusableText(
                                      text: "Quên mật khẩu?",
                                      style: appStyle(
                                          12, Colors.blue, FontWeight.normal))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Obx(() => CustomButton(
                              text: "Đăng Nhập",
                              onTap: controller.isLoading
                                  ? null
                                  : () {
                                      final isValid =
                                          _formKey.currentState?.validate() ??
                                              false;
                                      if (!isValid) return;

                                      final model = LoginModel(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text);

                                      final data = loginModelToJson(model);
                                      controller.loginFunction(data);
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
