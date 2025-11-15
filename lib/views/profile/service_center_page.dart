import 'package:flutter/material.dart';

class ServiceCenterPage extends StatelessWidget {
  const ServiceCenterPage({super.key});

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
          'Trung tâm dịch vụ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Tính năng đang phát triển. Vui lòng quay lại sau.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
