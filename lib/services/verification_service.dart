import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/phone_verification_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationService {
  final controller = Get.put(PhoneVerificationController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber(String phoneNumber,
      {required Null Function(String verificationId, int? resendToken)
          codeSent}) async {
    debugPrint('verifyPhoneNumber start: $phoneNumber');
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('verificationCompleted: auto credential received');
        controller.verifyPhone();
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('verificationFailed: ${e.code} - ${e.message}');
        Get.snackbar(
            'Gửi mã thất bại', e.message ?? 'Lỗi xác thực số điện thoại',
            colorText: kLightWhite, backgroundColor: kRed);
      },
      codeSent: (String verificationId, int? resendToken) {
        debugPrint(
            'codeSent: verificationId=$verificationId resendToken=$resendToken');
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('codeAutoRetrievalTimeout: $verificationId');
      },
    );
  }

  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    debugPrint('verifySmsCode: verificationId=$verificationId, code=$smsCode');
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    try {
      await _auth.signInWithCredential(credential);
      controller.verifyPhone();
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      Get.snackbar(
          'Xác minh thất bại', e.message ?? 'Không thể đăng nhập bằng mã OTP',
          colorText: kLightWhite, backgroundColor: kRed);
    } catch (e) {
      debugPrint('Unknown error at signInWithCredential: $e');
      Get.snackbar(
          'Xác minh thất bại', 'Lỗi không xác định khi đăng nhập bằng mã OTP',
          colorText: kLightWhite, backgroundColor: kRed);
    }
  }
}
