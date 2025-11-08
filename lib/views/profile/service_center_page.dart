import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ServiceCenterPage extends StatelessWidget {
  const ServiceCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung tâm dịch vụ'),
        leading: const Icon(AntDesign.customerservice),
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