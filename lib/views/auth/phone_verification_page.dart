import 'package:flutter/material.dart';
import 'package:phone_otp_verification/phone_verification.dart';

class PhoneVerificationPage extends StatelessWidget {
  const PhoneVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneVerification(
      isFirstPage: true,
      enableLogo: false,
      themeColor: Colors.blueAccent,
      backgroundColor: Colors.black,
      initialPageText: "Verify Phone Number",
      initialPageTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textColor: Colors.white,
      onSend: (String value) {
        print('Phone number: $value');
      },
      onVerification: (String value) {
        print('OTP: $value');
      },
    );
  }
}
