import 'dart:convert';
import 'package:appliances_flutter/common/app_style.dart';
import 'package:appliances_flutter/common/back_ground_container.dart';
import 'package:appliances_flutter/common/reusable_text.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/extensions/auto_tr_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:appliances_flutter/utils/currency.dart';
import 'package:appliances_flutter/services/language_service.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> available = [];
  List<Map<String, dynamic>> claimed = [];
  bool isLoading = true;
  late TabController _tabController;
  // Debug log buffer for FE
  String _debugLog = '';
  final LanguageService _languageService = LanguageService();
  void _log(String msg) {
    final line = '[VoucherFE] ${DateTime.now().toIso8601String()}  $msg';
    debugPrint(line);
    _debugLog = (_debugLog + line + '\n');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      isLoading = true;
    });
    try {
      final box = GetStorage();
      final token = box.read('token');
      _debugLog = '';
      _log(
          'Start fetchAll, tokenPresent=${token != null}, baseUrl=$appBaseUrl');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      List<Map<String, dynamic>> avail = [];
      List<Map<String, dynamic>> mine = [];
      // Fetch available (auth-first). If empty, always fallback to public.
      try {
        final uriAvail = Uri.parse('${appBaseUrl}/api/voucher/available');
        _log('GET /available -> ${uriAvail.toString()}');
        final respAvail = await http.get(uriAvail, headers: headers);
        _log(
            'Resp /available: status=${respAvail.statusCode}, bytes=${respAvail.bodyBytes.length}');
        if (respAvail.statusCode == 200) {
          final j1 = jsonDecode(respAvail.body);
          if (j1 is Map && j1['status'] == true && j1['data'] is List) {
            avail = List<Map<String, dynamic>>.from(j1['data']);
            _log('Parsed /available: count=${avail.length}');
          }
        }
      } catch (e) {
        _log('Error /available: $e');
      }
      // Public fallback when empty (covers: not logged in, 401/403, or 200 with empty list)
      if (avail.isEmpty) {
        try {
          final uriPublic = Uri.parse('${appBaseUrl}/api/voucher/public');
          _log('Fallback GET /public -> ${uriPublic.toString()}');
          final publicResp = await http.get(uriPublic);
          _log(
              'Resp /public: status=${publicResp.statusCode}, bytes=${publicResp.bodyBytes.length}');
          if (publicResp.statusCode == 200) {
            final pj = jsonDecode(publicResp.body);
            if (pj is Map && pj['status'] == true && pj['data'] is List) {
              avail = List<Map<String, dynamic>>.from(pj['data']);
              _log('Parsed /public: count=${avail.length}');
            }
          }
        } catch (e) {
          _log('Error /public: $e');
        }
      }

      // Fetch my claimed (auth only)
      try {
        if (token != null) {
          final uriMy = Uri.parse('${appBaseUrl}/api/voucher/my');
          _log('GET /my -> ${uriMy.toString()}');
          final respMy = await http.get(uriMy, headers: headers);
          _log(
              'Resp /my: status=${respMy.statusCode}, bytes=${respMy.bodyBytes.length}');
          if (respMy.statusCode == 200) {
            final j2 = jsonDecode(respMy.body);
            if (j2 is Map && j2['status'] == true && j2['data'] is List) {
              mine = List<Map<String, dynamic>>.from(j2['data']);
              _log('Parsed /my: count=${mine.length}');
            }
          }
        }
      } catch (e) {
        _log('Error /my: $e');
      }
      setState(() {
        available = avail;
        claimed = mine;
        isLoading = false;
      });
      _log(
          'Final state: available=${available.length}, claimed=${claimed.length}');
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
      _log('fetchAll exception: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _copyVoucherCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'voucher_copy_title'.tr,
      'voucher_copy_message'.trParams({'code': code}),
      backgroundColor: kPrimary,
      colorText: kLightWhite,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _claimVoucher(String code) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      if (token == null) {
        Get.snackbar('voucher_login_required'.tr, 'voucher_login_message'.tr,
            backgroundColor: kRed, colorText: kLightWhite);
        return;
      }
      _log('POST /claim code=$code');
      final resp = await http.post(
        Uri.parse('$appBaseUrl/api/voucher/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      );
      _log(
          'Resp /claim: status=${resp.statusCode}, bytes=${resp.bodyBytes.length}');
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['status'] == true) {
        Get.snackbar('voucher_claim_success_title'.tr,
            'voucher_claim_success_message'.trParams({'code': code}),
            backgroundColor: kPrimary, colorText: kLightWhite);
        await _fetchAll();
      } else {
        _log('Claim failed: ${data['message'] ?? 'unknown'}');
        Get.snackbar('voucher_claim_fail_title'.tr,
            data['message'] ?? 'voucher_claim_retry'.tr,
            backgroundColor: kRed, colorText: kLightWhite);
      }
    } catch (e) {
      _log('Claim exception: $e');
      Get.snackbar('voucher_error_title'.tr, e.toString(),
          backgroundColor: kRed, colorText: kLightWhite);
    }
  }

  String _discountText(Map<String, dynamic> v) {
    final type = v['type'];
    final value = (v['value'] ?? 0);
    final maxDiscount = v['maxDiscount'];
    final isEnglish = _languageService.isEnglish();
    if (type == 'percentage') {
      String text =
          isEnglish ? 'Save ${value.toString()}%' : 'Giảm ${value.toString()}%';
      if (maxDiscount != null) {
        final cap = usdToVndText((maxDiscount as num).toDouble());
        text += isEnglish ? ' (Up to $cap)' : ' (Tối đa $cap)';
      }
      return text;
    }
    final absolute = usdToVndText((value as num).toDouble());
    return isEnglish ? 'Save $absolute' : 'Giảm $absolute';
  }

  String? _minOrderText(Map<String, dynamic> v) {
    final min = v['minOrderTotal'];
    if (min == null) return null;
    final n = (min as num).toDouble();
    if (n <= 0) return null;
    return 'voucher_min_order'.trParams({'amount': usdToVndText(n)});
  }

  String? _expiryText(Map<String, dynamic> v) {
    final raw = v['validUntil'];
    if (raw == null) return null;
    try {
      final dt = DateTime.parse(raw.toString());
      final formatted = DateFormat('dd/MM/yyyy').format(dt);
      return _languageService.isEnglish()
          ? 'Expires: $formatted'
          : 'HSD: $formatted';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kLightWhite,
        elevation: 0,
        title: ReusableText(
          text: 'vouchers'.tr,
          style: appStyle(18, kLightWhite, FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: 'voucher_view_log'.tr,
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.6,
                  minChildSize: 0.3,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SelectableText(
                          _debugLog.isEmpty ? 'voucher_no_log'.tr : _debugLog,
                          style: TextStyle(fontSize: 12.sp, color: kDark),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kLightWhite,
          tabs: [
            Tab(text: 'voucher_tab_available'.tr),
            Tab(text: 'voucher_tab_claimed'.tr),
          ],
        ),
      ),
      body: BackGroundContainer(
        color: kLightWhite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Available to claim
                  RefreshIndicator(
                    onRefresh: _fetchAll,
                    child: available.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_giftcard,
                                    size: 100.h, color: kGray),
                                SizedBox(height: 16.h),
                                ReusableText(
                                  text: 'voucher_empty_available'.tr,
                                  style: appStyle(16, kGray, FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(12.w),
                            itemCount: available.length,
                            itemBuilder: (context, index) {
                              final v = available[index];
                              final code = v['code'] ?? '';
                              final title = v['title'] ?? code;
                              final discountLine = _discountText(v);
                              final minOrderLine = _minOrderText(v);
                              final expiryLine = _expiryText(v);
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.local_offer,
                                      color: kPrimary),
                                  title: ReusableText(
                                    text: title,
                                    style: appStyle(13, kDark, FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    autoTranslate: true,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ReusableText(
                                        text: discountLine,
                                        style: appStyle(
                                            12, kDark, FontWeight.w400),
                                        autoTranslate: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (minOrderLine != null)
                                        ReusableText(
                                          text: minOrderLine,
                                          style: appStyle(
                                              11, kGray, FontWeight.w400),
                                          autoTranslate: true,
                                        ),
                                      if (expiryLine != null)
                                        ReusableText(
                                          text: expiryLine,
                                          style: appStyle(
                                              11, kGray, FontWeight.w400),
                                          autoTranslate: true,
                                        ),
                                    ],
                                  ),
                                  trailing: TextButton(
                                    onPressed: () => _claimVoucher(code),
                                    child: Text('voucher_button_claim'.tr),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Claimed
                  RefreshIndicator(
                    onRefresh: _fetchAll,
                    child: claimed.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: 100.h, color: kGray),
                                SizedBox(height: 16.h),
                                ReusableText(
                                  text: 'voucher_empty_claimed'.tr,
                                  style: appStyle(16, kGray, FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(12.w),
                            itemCount: claimed.length,
                            itemBuilder: (context, index) {
                              final v = claimed[index];
                              final code = v['code'] ?? '';
                              final title = v['title'] ?? code;
                              final used = v['used'] == true;
                              final discountLine = _discountText(v);
                              final minOrderLine = _minOrderText(v);
                              final expiryLine = _expiryText(v);
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    used
                                        ? Icons.lock_clock
                                        : Icons.check_circle,
                                    color: used ? kGray : kSecondary,
                                  ),
                                  title: ReusableText(
                                    text: title,
                                    style: appStyle(13, kDark, FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    autoTranslate: true,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ReusableText(
                                        text: code,
                                        style: appStyle(
                                            12, kDark, FontWeight.w500),
                                      ),
                                      ReusableText(
                                        text: discountLine,
                                        style: appStyle(
                                            12, kDark, FontWeight.w400),
                                        autoTranslate: true,
                                      ),
                                      if (minOrderLine != null)
                                        ReusableText(
                                          text: minOrderLine,
                                          style: appStyle(
                                              11, kGray, FontWeight.w400),
                                          autoTranslate: true,
                                        ),
                                      if (expiryLine != null)
                                        ReusableText(
                                          text: expiryLine,
                                          style: appStyle(
                                              11, kGray, FontWeight.w400),
                                          autoTranslate: true,
                                        ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: used ? kGrayLight : kPrimaryLight,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      used
                                          ? 'voucher_status_used'.tr
                                          : 'voucher_status_claimed'.tr,
                                      style: TextStyle(
                                          color: used ? kDark : kPrimary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  onLongPress: () => _copyVoucherCode(code),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
