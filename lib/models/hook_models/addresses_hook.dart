import 'dart:ui';

import 'package:appliances_flutter/models/address_response.dart';

class FetchAddresses {
  final List<AddressResponse>? data;
  final bool isLoading;
  final Exception? error;
  final VoidCallback? refetch;

  FetchAddresses({
    this.data,
    required this.isLoading,
    this.error,
    this.refetch,
  });
}