import 'package:appliances_flutter/models/address_response.dart';
import 'package:flutter/material.dart';

class FetchAddresses {
  final List<AddressResponse>? data;
  final bool isLoading;
  final Exception? error;
  final VoidCallback? refetch;

  FetchAddresses({
    required this.data,
    required this.isLoading,
    required this.error,
    required this.refetch,
  });
}
