// ignore_for_file: prefer_final_fields, unused_local_variable

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

  void searchFoods(String key) async {
    _lastSearchKey = key;
    _lastFilters = null; // Clear filters on new search
    setLoading = true;

    Uri url = Uri.parse("$appBaseUrl/api/appliances/search/$key");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        searchResults = appliancesModelFromJson(response.body);
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
    _lastSearchKey = searchKey;
    _lastFilters = Map.from(filters); // Save filters
    setLoading = true;

    // Build query parameters
    String queryParams = '';
    if (filters['category'] != null && filters['category'] != 'Tất cả') {
      queryParams += '&category=${filters['category']}';
    }
    if (filters['minPrice'] != null) {
      queryParams += '&minPrice=${filters['minPrice']}';
    }
    if (filters['maxPrice'] != null) {
      queryParams += '&maxPrice=${filters['maxPrice']}';
    }
    if (filters['minRating'] != null) {
      queryParams += '&minRating=${filters['minRating']}';
    }
    if (filters['sortBy'] != null && filters['sortBy'] != 'default') {
      queryParams += '&sortBy=${filters['sortBy']}';
    }

    Uri url =
        Uri.parse("$appBaseUrl/api/appliances/search/$searchKey?$queryParams");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        searchResults = appliancesModelFromJson(response.body);
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
}
