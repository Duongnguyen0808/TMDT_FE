import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/controllers/service_center_controller.dart';
import 'package:appliances_flutter/models/service_ticket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceTicketFormPage extends StatefulWidget {
  const ServiceTicketFormPage({super.key});

  @override
  State<ServiceTicketFormPage> createState() => _ServiceTicketFormPageState();
}

class _ServiceTicketFormPageState extends State<ServiceTicketFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;

  late final ServiceCenterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceCenterController>();
    final categories = _categoryValues();
    final priorities = _priorityValues();
    _selectedCategory = categories.isNotEmpty ? categories.first : null;
    _selectedPriority = priorities.isNotEmpty ? priorities.first : null;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  List<String> _categoryValues() {
    final meta = controller.metadata['categories'];
    if (meta != null && meta.isNotEmpty) return meta;
    return List<String>.from(ServiceTicket.defaultCategories);
  }

  List<String> _priorityValues() {
    final meta = controller.metadata['priorities'];
    if (meta != null && meta.isNotEmpty) return meta;
    return List<String>.from(ServiceTicket.defaultPriorities);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await controller.createTicket(
      subject: _subjectCtrl.text,
      description: _descriptionCtrl.text,
      category: _selectedCategory,
      priority: _selectedPriority,
    );
    if (ok && mounted) {
      Get.back();
      Get.snackbar(
        'Trung tâm dịch vụ',
        'Đã gửi yêu cầu hỗ trợ thành công',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kPrimary,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryValues();
    final priorities = _priorityValues();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text('Tạo yêu cầu mới',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề',
                      hintText: 'Ví dụ: Giao hàng bị trễ',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tiêu đề';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Danh mục'),
                    items: categories
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(ServiceTicket.labelForCategory(c))))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(labelText: 'Mức ưu tiên'),
                    items: priorities
                        .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(ServiceTicket.labelForPriority(p))))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPriority = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả chi tiết',
                      hintText: 'Hãy cho chúng tôi biết rõ vấn đề bạn gặp phải',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 20) {
                        return 'Vui lòng mô tả ít nhất 20 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    final busy = controller.submitting.value;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(busy ? 'Đang gửi...' : 'Gửi yêu cầu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: busy ? null : _submit,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
