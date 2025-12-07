// ignore_for_file: prefer_final_fields, unused_local_variable

import 'dart:convert';

import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/models/api_error.dart';
import 'package:appliances_flutter/models/appliances_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SearchAppliancesController extends GetxController {
  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool value) {
    _isLoading.value = value;
  }

  RxBool _isTriggered = false.obs;

  bool get isTriggered => _isTriggered.value;

  set setTrigger(bool value) {
    _isTriggered.value = value;
  }

  List<AppliancesModel>? searchResults;

  // Save last applied filters
  Map<String, dynamic>? _lastFilters;
  String? _lastSearchKey;

  Map<String, dynamic>? get lastFilters => _lastFilters;
  String? get lastSearchKey => _lastSearchKey;

  Future<void> fetchAllProducts() async {
    _lastSearchKey = null;
    _lastFilters = null;
    setLoading = true;
    try {
      final response =
          await http.get(Uri.parse("$appBaseUrl/api/appliances/all"));
      if (response.statusCode == 200) {
        searchResults = _decodeProducts(response.body);
        setTrigger = false;
      } else {
        apiErrorFromJson(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setLoading = false;
    }
  }

  void searchFoods(String key) async {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      return;
    }

    _lastSearchKey = trimmedKey;
    _lastFilters = null; // Clear filters on new search
    setLoading = true;

    final encodedKey = Uri.encodeComponent(trimmedKey);
    final Uri url = Uri.parse("$appBaseUrl/api/appliances/search/$encodedKey");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        searchResults = _decodeProducts(response.body);
        setLoading = false;
      } else {
        setLoading = false;
        var error = apiErrorFromJson(response.body);
      }
    } catch (e) {
      setLoading = false;
      debugPrint(e.toString());
    }
  }

  void applyFilters(String searchKey, Map<String, dynamic> filters) async {
    final trimmedKey = searchKey.trim();
    final hasKeyword =
        trimmedKey.isNotEmpty || (_lastSearchKey?.isNotEmpty ?? false);

    _lastSearchKey = trimmedKey.isNotEmpty ? trimmedKey : _lastSearchKey;
    _lastFilters = Map.from(filters); // Save filters
    setLoading = true;

    final Map<String, String> queryParams = {};

    final dynamic categoryValue = filters['category'];
    if (categoryValue != null &&
        categoryValue != 'all' &&
        categoryValue != 'Tất cả') {
      queryParams['category'] = categoryValue.toString();
    }

    final dynamic minPrice = filters['minPrice'];
    if (minPrice != null) {
      queryParams['minPrice'] = (minPrice is num
              ? minPrice
              : double.tryParse(minPrice.toString()) ?? 0)
          .round()
          .toString();
    }

    final dynamic maxPrice = filters['maxPrice'];
    if (maxPrice != null) {
      queryParams['maxPrice'] = (maxPrice is num
              ? maxPrice
              : double.tryParse(maxPrice.toString()) ?? 0)
          .round()
          .toString();
    }

    final dynamic minRating = filters['minRating'];
    if (minRating != null) {
      queryParams['minRating'] = (minRating is num
              ? minRating
              : double.tryParse(minRating.toString()) ?? 0)
          .toString();
    }

    final sortBy = filters['sortBy'];
    if (sortBy != null && sortBy != 'default') {
      queryParams['sortBy'] = sortBy.toString();
    }

    final bool hasFilters = queryParams.isNotEmpty;

    if (!hasKeyword && !hasFilters) {
      await fetchAllProducts();
      return;
    }

    Uri url;
    if (trimmedKey.isNotEmpty) {
      final encodedKey = Uri.encodeComponent(trimmedKey);
      url = Uri.parse("$appBaseUrl/api/appliances/search/$encodedKey")
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    } else {
      url = Uri.parse("$appBaseUrl/api/appliances/advanced/search")
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    }

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        searchResults = _decodeProducts(response.body);
        setLoading = false;
      } else {
        setLoading = false;
        var error = apiErrorFromJson(response.body);
      }
    } catch (e) {
      setLoading = false;
      debugPrint(e.toString());
    }
  }

  List<AppliancesModel> _decodeProducts(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded
            .map((item) => AppliancesModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is List) {
          return data
              .map((item) => AppliancesModel.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      return appliancesModelFromJson(body);
    } catch (_) {
      return [];
    }
  }
}
