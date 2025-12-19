import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:appliances_flutter/constants/constants.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _box = GetStorage();
  final _cache = <String, _CacheEntry>{};
  Duration defaultTtl = const Duration(seconds: 30);
  // Use the same base URL as app constants to work on real devices
  static String get baseUrl => appBaseUrl;

  String? _token() => _box.read('token');

  Map<String, String> _headers({Map<String, String>? extra}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    final t = _token();
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    if (extra != null) h.addAll(extra);
    return h;
  }

  Future<ApiResponse> get(String path,
      {bool useCache = true, Duration? ttl, int retries = 1}) async {
    final url = Uri.parse(baseUrl + path);
    final key = url.toString();
    if (useCache) {
      final hit = _cache[key];
      if (hit != null && !hit.isExpired) {
        return ApiResponse(200, hit.data, fromCache: true);
      }
    }
    http.Response res;
    int attempt = 0;
    while (true) {
      try {
        res = await http.get(url, headers: _headers());
        break;
      } catch (e) {
        if (attempt++ >= retries) rethrow;
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      body = res.body;
    }
    if (res.statusCode == 200 && useCache) {
      _cache[key] = _CacheEntry(body, ttl ?? defaultTtl);
    }
    if (kDebugMode) debugPrint('[ApiClient] GET ${res.statusCode} $url');
    return ApiResponse(res.statusCode, body);
  }

  Future<ApiResponse> post(String path, {Object? data, int retries = 0}) async {
    final url = Uri.parse(baseUrl + path);
    http.Response res;
    int attempt = 0;
    while (true) {
      try {
        res = await http.post(url,
            headers: _headers(), body: data == null ? null : jsonEncode(data));
        break;
      } catch (e) {
        if (attempt++ >= retries) rethrow;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      body = res.body;
    }
    if (kDebugMode) debugPrint('[ApiClient] POST ${res.statusCode} $url');
    return ApiResponse(res.statusCode, body);
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expireAt;
  _CacheEntry(this.data, Duration ttl) : expireAt = DateTime.now().add(ttl);
  bool get isExpired => DateTime.now().isAfter(expireAt);
}

class ApiResponse {
  final int statusCode;
  final dynamic data;
  final bool fromCache;
  ApiResponse(this.statusCode, this.data, {this.fromCache = false});
  bool get ok => statusCode >= 200 && statusCode < 300;
}
