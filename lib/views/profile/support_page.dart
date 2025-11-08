import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ khách hàng')),
      body: const Center(
        child: Text(
          'Liên hệ hỗ trợ: support@tmdt.local\nHotline: 1900-0000',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}