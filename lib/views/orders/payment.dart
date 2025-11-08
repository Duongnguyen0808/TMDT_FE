import 'package:appliances_flutter/controllers/orders_controller.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final orderController = Get.put(OrdersController());
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // debugPrint('Page started loading: ${paymentNotifier.paymentUrl}');
          },
          onPageFinished: (String url) {
            // debugPrint('Page finished loading: $url');
          },

          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            if (url.isEmpty) return;

            // Thành công: chuyển về trang chủ và hiển thị thông báo
            if (url.contains("checkout-success")) {
              orderController.setPaymentUrl = '';
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bạn đã thanh toán thành công')),
              );
              Get.offAll(() => MainScreen());
              return;
            }
            if (url.contains("cancel")) {
              // Hủy thanh toán: quay lại trang đặt hàng để chọn phương thức khác
              orderController.setPaymentUrl = '';
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã hủy thanh toán. Vui lòng chọn lại phương thức.'),
                ),
              );
              // Quay lại trang chọn phương thức thanh toán
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return;
            }

            // Xử lý VNPay return page
            if (url.contains("vnpay_return")) {
              final uri = Uri.parse(url);
              final rsp = uri.queryParameters['vnp_ResponseCode'];
              orderController.setPaymentUrl = '';
              if (rsp == '00') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn đã thanh toán thành công')),
                );
                Get.offAll(() => MainScreen());
              } else {
                // Lỗi từ VNPay: hiển thị thông báo và quay lại trang đặt hàng
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thanh toán VNPay thất bại (mã $rsp). Vui lòng chọn lại phương thức.')),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(orderController.paymentUrl));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: WebViewWidget(controller: _controller));
  }
}
