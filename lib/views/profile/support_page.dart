import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF30b9b2),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Hỗ trợ khách hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Liên hệ hỗ trợ: support@tmdt.local\nHotline: 1900-0000',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
