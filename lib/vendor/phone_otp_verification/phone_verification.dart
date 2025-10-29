import 'package:appliances_flutter/utils/input_formatters/grouped_digits_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:get/get.dart';

/// Local vendor of PhoneVerification widget with Vietnamese texts.
/// Preserves the public API used by the app: onSend and onVerification.
class PhoneVerification extends StatefulWidget {
  final bool isFirstPage;
  final bool enableLogo;
  final Color themeColor;
  final Color backgroundColor;
  final String? initialPageText;
  final TextStyle? initialPageTextStyle;
  final Color? textColor;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onVerification;

  const PhoneVerification({
    super.key,
    this.isFirstPage = false,
    this.enableLogo = false,
    required this.themeColor,
    required this.backgroundColor,
    this.initialPageText,
    this.initialPageTextStyle,
    this.textColor,
    required this.onSend,
    required this.onVerification,
  });

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  String _countryCode = '+84';
  bool _sentCode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.textColor ?? kDark;
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kDark,
          onPressed: () {
            if (_sentCode) {
              setState(() => _sentCode = false);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          _sentCode
              ? 'Nhập mã xác minh'
              : (widget.initialPageText ?? 'Xác minh số điện thoại'),
          style: appStyle(16, kPrimary, FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _sentCode ? _buildOtp(textColor) : _buildPhone(textColor),
        ),
      ),
    );
  }

  Widget _buildPhone(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.initialPageText ?? 'Xác minh số điện thoại',
          style: widget.initialPageTextStyle ??
              appStyle(20, widget.themeColor, FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text('Khu vực', style: appStyle(14, textColor, FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _countryCode,
          items: const [
            DropdownMenuItem(value: '+84', child: Text('Việt Nam (+84)')),
            DropdownMenuItem(value: '+1', child: Text('Hoa Kỳ (+1)')),
          ],
          onChanged: (v) => setState(() => _countryCode = v ?? '+84'),
        ),
        const SizedBox(height: 16),
        Text('Số điện thoại', style: appStyle(14, textColor, FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
            GroupedDigitsInputFormatter(groupSize: 3),
          ],
          decoration: InputDecoration(
            prefixText: '$_countryCode ',
            hintText: 'Nhập số điện thoại',
            border: const UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onSend,
            style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
            child: const Text('Gửi mã'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Số điện thoại phía trên chỉ dùng cho xác minh đăng nhập. Vui lòng kiểm tra mã quốc gia và nhập số.',
          style: appStyle(12, textColor, FontWeight.normal),
        )
      ],
    );
  }

  Widget _buildOtp(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nhập mã xác minh',
            style: appStyle(18, widget.themeColor, FontWeight.bold)),
        const SizedBox(height: 12),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _otpBox(i, textColor)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onVerify,
            style: ElevatedButton.styleFrom(backgroundColor: widget.themeColor),
            child: const Text('Xác minh và đăng nhập'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Nếu không nhận được mã, hãy kiểm tra lại số điện thoại hoặc gửi lại.',
                style: appStyle(12, textColor, FontWeight.normal),
              ),
            ),
            TextButton(
              onPressed: _onResend,
              child: const Text('Gửi lại mã'),
            )
          ],
        )
      ],
    );
  }

  Widget _otpBox(int index, Color textColor) {
    return SizedBox(
      width: 40,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          counterText: '',
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
          } else if (v.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
          }
        },
        onSubmitted: (_) {
          if (index < 5) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
          }
        },
      ),
    );
  }

  void _onSend() {
    final raw = _phoneController.text.trim().replaceAll(' ', '');
    if (raw.isEmpty) {
      Get.snackbar(
        'Vui lòng nhập số điện thoại',
        'Hãy điền số để tiếp tục',
        backgroundColor: kPrimary,
        colorText: kLightWhite,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.phone_android, color: kLightWhite),
        duration: const Duration(seconds: 3),
      );
      return;
    }
    // Gọi callback của app, giữ nguyên logic ở phía ngoài
    widget.onSend(_phoneController.text);
    setState(() => _sentCode = true);
  }

  void _onVerify() {
    final code = _otpControllers.map((c) => c.text).join();
    widget.onVerification(code);
  }

  void _onResend() {
    // Gọi lại gửi mã dựa trên số đang nhập ở bước trước
    final raw = _phoneController.text.trim().replaceAll(' ', '');
    if (raw.isEmpty) {
      Get.snackbar(
        'Vui lòng nhập số điện thoại',
        'Hãy điền số để tiếp tục',
        backgroundColor: kPrimary,
        colorText: kLightWhite,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        icon: const Icon(Icons.phone_android, color: kLightWhite),
        duration: const Duration(seconds: 3),
      );
      setState(() => _sentCode = false);
      return;
    }
    widget.onSend(_phoneController.text);
    Get.snackbar(
      'Đã gửi lại mã xác minh',
      'Vui lòng kiểm tra SMS',
      backgroundColor: kPrimary,
      colorText: kLightWhite,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.sms_outlined, color: kLightWhite),
      duration: const Duration(seconds: 3),
    );
  }
}
